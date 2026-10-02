import SwiftUI
import AppKit
import SwiftTerm

/// What the embedded terminal launches.
enum TerminalMode: String, CaseIterable, Identifiable {
    case shell
    case agent
    case host

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shell: return "Sandbox shell"
        case .agent: return "Agent session"
        case .host: return "Host shell"
        }
    }

    var systemImage: String {
        switch self {
        case .shell: return "shippingbox"
        case .agent: return "sparkles"
        case .host: return "laptopcomputer"
        }
    }
}

/// SwiftUI wrapper around SwiftTerm's pseudo-terminal-backed terminal view.
struct LocalTerminalView: NSViewRepresentable {
    let executable: String
    let arguments: [String]
    let environment: [String]
    var onTitle: (String) -> Void = { _ in }
    var onExit: (Int32?) -> Void = { _ in }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> LocalProcessTerminalView {
        let view = LocalProcessTerminalView(frame: .zero)
        view.processDelegate = context.coordinator
        view.configureNativeColors()
        context.coordinator.start(in: view)
        return view
    }

    func updateNSView(_ nsView: LocalProcessTerminalView, context: Context) {
        context.coordinator.parent = self
    }

    final class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
        var parent: LocalTerminalView

        init(_ parent: LocalTerminalView) { self.parent = parent }

        func start(in view: LocalProcessTerminalView) {
            view.startProcess(
                executable: parent.executable,
                args: parent.arguments,
                environment: parent.environment
            )
        }

        func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

        func setTerminalTitle(source: LocalProcessTerminalView, title: String) {
            let value = title
            DispatchQueue.main.async { self.parent.onTitle(value) }
        }

        func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

        func processTerminated(source: TerminalView, exitCode: Int32?) {
            let code = exitCode
            DispatchQueue.main.async { self.parent.onExit(code) }
        }
    }
}

/// A window that hosts an embedded terminal attached to a cloud sandbox.
struct TerminalWindow: View {
    let sandboxID: String

    @EnvironmentObject var store: SandboxStore
    @Environment(\.dismissWindow) private var dismissWindow

    @State private var mode: TerminalMode = .shell
    @State private var token = 0
    @State private var exitCode: Int32?
    @State private var processTitle: String?

    private var sandbox: Sandbox? { store.sandboxes.first { $0.id == sandboxID } }
    private var displayName: String { sandbox?.displayName ?? sandboxID }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ZStack {
                LocalTerminalView(
                    executable: executable,
                    arguments: arguments,
                    environment: terminalEnvironment,
                    onTitle: { processTitle = $0 },
                    onExit: { exitCode = $0 }
                )
                .id(token)
                .background(Color.black)

                if let exitCode {
                    exitOverlay(exitCode)
                }
            }
        }
        .frame(minWidth: 760, minHeight: 460)
        .navigationTitle("Terminal — \(displayName)")
        .task { store.start() }
        .onChange(of: mode) { _, _ in restart() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            if let sandbox {
                StatusDot(running: sandbox.isRunning)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(displayName).font(.system(.headline, weight: .semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Picker("", selection: $mode) {
                ForEach(TerminalMode.allCases) { m in
                    Label(m.title, systemImage: m.systemImage).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 330)

            Button {
                restart()
            } label: {
                Label("Restart", systemImage: "arrow.clockwise")
            }
            .help("Restart the terminal process")

            Button {
                dismissWindow(id: "terminal", value: sandboxID)
            } label: {
                Image(systemName: "xmark")
            }
            .help("Close terminal")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private var subtitle: String {
        if let processTitle, !processTitle.isEmpty { return processTitle }
        switch mode {
        case .shell: return "sbx --cloud exec -it \(sandboxID) bash"
        case .agent: return "sbx --cloud attach \(sandboxID)"
        case .host: return "login shell on this Mac"
        }
    }

    // MARK: - Process configuration

    private var resolvedSbx: String { SbxClient.shared.locate() ?? "/opt/homebrew/bin/sbx" }

    private var executable: String {
        mode == .host ? "/bin/zsh" : resolvedSbx
    }

    private var arguments: [String] {
        switch mode {
        case .host: return ["-l"]
        case .shell: return ["--cloud", "exec", "-it", sandboxID, "bash"]
        case .agent: return ["--cloud", "attach", sandboxID]
        }
    }

    private var terminalEnvironment: [String] {
        [
            "TERM=xterm-256color",
            "PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "HOME=\(NSHomeDirectory())",
            "LANG=en_US.UTF-8"
        ]
    }

    private func restart() {
        exitCode = nil
        processTitle = nil
        token += 1
    }

    // MARK: - Exit overlay

    private func exitOverlay(_ code: Int32) -> some View {
        VStack(spacing: 14) {
            Image(systemName: code == 0 ? "checkmark.circle" : "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(code == 0 ? Color.green : Color.orange)
            Text("Process exited\(code != 0 ? " with code \(code)" : "")")
                .font(.headline)
            HStack(spacing: 10) {
                Button("Restart") { restart() }
                    .keyboardShortcut(.defaultAction)
                Button("Close") { dismissWindow(id: "terminal", value: sandboxID) }
            }
        }
        .padding(28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.quaternary))
        .shadow(radius: 24)
    }
}
