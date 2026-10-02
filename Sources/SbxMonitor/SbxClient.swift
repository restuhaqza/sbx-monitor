import Foundation

enum SbxError: LocalizedError {
    case binaryNotFound
    case commandFailed(code: Int32, message: String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return "Could not find the `sbx` CLI. Install Docker Sandboxes (brew install docker/tap/sbx) or set its path in Settings."
        case .commandFailed(let code, let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            return "sbx exited with code \(code): \(trimmed.isEmpty ? "no output" : trimmed)"
        case .decoding(let message):
            return "Could not parse sbx output: \(message)"
        }
    }
}

struct ProcessResult {
    let stdout: String
    let stderr: String
    let code: Int32
}

/// Thin wrapper around the `sbx` CLI, focused on `--cloud` commands.
final class SbxClient {
    static let shared = SbxClient()

    private let lock = NSLock()
    private var cachedPath: String?

    /// Optional user override from Settings.
    var overridePath: String? {
        get { UserDefaults.standard.string(forKey: "sbxPathOverride") }
        set {
            UserDefaults.standard.set(newValue, forKey: "sbxPathOverride")
            lock.lock(); cachedPath = nil; lock.unlock()
        }
    }

    private let candidatePaths = [
        "/opt/homebrew/bin/sbx",
        "/usr/local/bin/sbx",
        "/usr/bin/sbx",
        "\(NSHomeDirectory())/.local/bin/sbx",
        "\(NSHomeDirectory())/bin/sbx"
    ]

    func locate() -> String? {
        lock.lock(); defer { lock.unlock() }
        if let cachedPath { return cachedPath }
        let fm = FileManager.default

        if let override = overridePath, !override.isEmpty, fm.isExecutableFile(atPath: override) {
            cachedPath = override
            return override
        }
        for path in candidatePaths where fm.isExecutableFile(atPath: path) {
            cachedPath = path
            return path
        }
        // GUI apps do not inherit the shell PATH; ask a login shell.
        if let found = try? execute("/bin/zsh", ["-lc", "command -v sbx"]).stdout
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !found.isEmpty,
           fm.isExecutableFile(atPath: found) {
            cachedPath = found
            return found
        }
        return nil
    }

    // MARK: - Commands

    func listCloudSandboxes() throws -> [Sandbox] {
        let json = try runCloud(["ls", "--json"])
        do {
            return try JSONDecoder().decode(SandboxList.self, from: Data(json.utf8)).sandboxes
        } catch {
            throw SbxError.decoding(String(describing: error))
        }
    }

    func ttl(of sandbox: String) throws -> TTLInfo {
        let json = try runCloud(["ttl", sandbox, "--json"])
        do {
            return try JSONDecoder().decode(TTLInfo.self, from: Data(json.utf8))
        } catch {
            throw SbxError.decoding(String(describing: error))
        }
    }

    func version() throws -> VersionInfo? {
        guard let sbx = locate() else { throw SbxError.binaryNotFound }
        let result = try execute(sbx, ["version", "--json"])
        guard result.code == 0 else {
            throw SbxError.commandFailed(code: result.code, message: result.stderr)
        }
        return try? JSONDecoder().decode(VersionInfo.self, from: Data(result.stdout.utf8))
    }

    func stop(_ sandbox: String) throws {
        _ = try runCloud(["stop", sandbox])
    }

    func remove(_ sandbox: String) throws {
        _ = try runCloud(["rm", "--force", sandbox])
    }

    func extendTTL(_ sandbox: String, by duration: String) throws {
        _ = try runCloud(["ttl", "+\(duration)", sandbox])
    }

    func publish(_ sandbox: String, port: Int) throws {
        _ = try runCloud(["ports", sandbox, "--publish", "\(port)"])
    }

    func unpublish(_ sandbox: String, port: Int) throws {
        _ = try runCloud(["ports", sandbox, "--unpublish", "\(port)"])
    }

    // MARK: - Internals

    @discardableResult
    private func runCloud(_ args: [String]) throws -> String {
        guard let sbx = locate() else { throw SbxError.binaryNotFound }
        let result = try execute(sbx, ["--cloud"] + args)
        guard result.code == 0 else {
            throw SbxError.commandFailed(code: result.code, message: result.stderr.isEmpty ? result.stdout : result.stderr)
        }
        return result.stdout
    }

    @discardableResult
    private func execute(_ executable: String, _ args: [String]) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = args

        var env = ProcessInfo.processInfo.environment
        let extra = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
        env["PATH"] = env["PATH"].map { "\($0):\(extra)" } ?? extra
        // Keep output machine-readable and avoid interactive prompts.
        env["NO_COLOR"] = "1"
        process.environment = env
        process.standardInput = FileHandle.nullDevice

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        try process.run()

        // Drain both pipes concurrently to avoid a full-buffer deadlock.
        var outData = Data()
        var errData = Data()
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            errData = errPipe.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }
        process.waitUntilExit()
        group.wait()

        return ProcessResult(
            stdout: String(decoding: outData, as: UTF8.self),
            stderr: String(decoding: errData, as: UTF8.self),
            code: process.terminationStatus
        )
    }
}
