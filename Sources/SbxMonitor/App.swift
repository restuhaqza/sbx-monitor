import SwiftUI
import AppKit
import ServiceManagement
import SwiftTerm

@main
struct SbxMonitorApp: App {
    @StateObject private var store = SandboxStore()

    init() {
        // Diagnostic mode: `SbxMonitor --dump` prints the live cloud sandbox list as JSON and exits.
        if CommandLine.arguments.contains("--dump") {
            do {
                let list = try SbxClient.shared.listCloudSandboxes()
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                print(String(decoding: try encoder.encode(list), as: UTF8.self))
                exit(0)
            } catch {
                FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
                exit(1)
            }
        }

        // Terminal smoke test: instantiate the SwiftTerm view, run a command over a PTY, exit.
        if CommandLine.arguments.contains("--terminal-smoke") || CommandLine.arguments.contains("--terminal-smoke-sbx") {
            let useSbx = CommandLine.arguments.contains("--terminal-smoke-sbx")
            var executable = "/bin/echo"
            var args = ["terminal-smoke-ok"]
            var env = ["TERM=xterm-256color", "PATH=/usr/bin:/bin"]
            if useSbx {
                let id = CommandLine.arguments.last ?? ""
                executable = SbxClient.shared.locate() ?? "/opt/homebrew/bin/sbx"
                args = ["--cloud", "exec", "-it", id, "bash", "-lc", "echo SBX_PTY_OK; exit"]
                env = ["TERM=xterm-256color",
                       "PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
                       "HOME=\(NSHomeDirectory())"]
            }
            let app = NSApplication.shared
            app.setActivationPolicy(.accessory)
            let view = LocalProcessTerminalView(frame: NSRect(x: 0, y: 0, width: 800, height: 400))
            let window = NSWindow(contentRect: view.frame, styleMask: [.titled], backing: .buffered, defer: false)
            window.contentView = view
            window.makeKeyAndOrderFront(nil)
            view.startProcess(executable: executable, args: args, environment: env)
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                print("SMOKE ok — process running=\(view.process?.running ?? false)")
                exit(0)
            }
            app.run()
            exit(0)
        }

        // Launch-at-login diagnostics (run from inside the .app bundle).
        if CommandLine.arguments.contains("--login-status") {
            print(SMAppService.mainApp.status.label)
            exit(0)
        }
        if CommandLine.arguments.contains("--login-enable") {
            do {
                try SMAppService.mainApp.register()
                print("register ok, status=\(SMAppService.mainApp.status.label)")
            } catch {
                FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
                exit(1)
            }
            exit(0)
        }
        if CommandLine.arguments.contains("--login-disable") {
            do {
                try SMAppService.mainApp.unregister()
                print("unregister ok, status=\(SMAppService.mainApp.status.label)")
            } catch {
                FileHandle.standardError.write(Data("error: \(error.localizedDescription)\n".utf8))
                exit(1)
            }
            exit(0)
        }
    }

    var body: some Scene {
        Window("Sbx Monitor", id: "main") {
            MainWindowView()
                .environmentObject(store)
                .frame(minWidth: 760, minHeight: 460)
                .task { store.start() }
        }
        .defaultSize(width: 980, height: 640)

        WindowGroup(id: "terminal", for: String.self) { $sandboxID in
            TerminalWindow(sandboxID: sandboxID ?? "")
                .environmentObject(store)
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(store)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: store.runningCount > 0 ? "shippingbox.fill" : "shippingbox")
                if !store.sandboxes.isEmpty {
                    Text("\(store.sandboxes.count)")
                }
            }
            .task { store.start() }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(store)
        }
    }
}
