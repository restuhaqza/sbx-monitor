import Foundation

/// An exposed port on a cloud sandbox.
struct PortInfo: Codable, Identifiable, Hashable {
    let hostIP: String?
    let hostPort: Int?
    let sandboxPort: Int
    let proto: String?
    let url: String?

    var id: String { url ?? "\(sandboxPort)/\(proto ?? "tcp")" }
    var label: String { "\(sandboxPort)/\(proto ?? "tcp")" }

    enum CodingKeys: String, CodingKey {
        case hostIP = "host_ip"
        case hostPort = "host_port"
        case sandboxPort = "sandbox_port"
        case proto = "protocol"
        case url
    }
}

/// A cloud sandbox as reported by `sbx --cloud ls --json`.
struct Sandbox: Codable, Identifiable, Hashable {
    let name: String
    let id: String
    let agent: String?
    let status: String
    let cpus: Int?
    let memoryMiB: Int?
    let image: String?
    let createdAt: String?
    let expiresAt: String?
    let ports: [PortInfo]?

    enum CodingKeys: String, CodingKey {
        case name, id, agent, status, cpus, image, ports
        case memoryMiB = "memory_mib"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

struct SandboxList: Codable {
    let sandboxes: [Sandbox]
}

/// Result of `sbx --cloud ttl <sandbox> --json`.
struct TTLInfo: Codable {
    let id: String
    let expiresAt: String
    let expiresInSeconds: Int
    let maxRemainingSeconds: Int

    enum CodingKeys: String, CodingKey {
        case id
        case expiresAt = "expires_at"
        case expiresInSeconds = "expires_in_seconds"
        case maxRemainingSeconds = "max_remaining_seconds"
    }
}

struct VersionInfo: Codable {
    struct Component: Codable {
        let version: String?
        let state: String?
        let revision: String?
    }
    let client: Component?
    let server: Component?
}

extension Sandbox {
    var isRunning: Bool { status.lowercased() == "running" }
    var displayName: String { name.isEmpty ? id : name }
    var expiresDate: Date? { DateParser.parse(expiresAt) }
    var createdDate: Date? { DateParser.parse(createdAt) }
    var hasPorts: Bool { !(ports ?? []).isEmpty }
}

enum DateParser {
    static let withFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static let plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func parse(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        return withFraction.date(from: string) ?? plain.date(from: string)
    }
}
