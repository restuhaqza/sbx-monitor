import AppKit
import UserNotifications

enum Clipboard {
    static func copy(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
    }
}

enum Shell {
    static func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }
    /// Runs a command in a new Terminal window.
    static func openInTerminal(_ command: String) {
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let source = """
        tell application "Terminal"
            activate
            do script "\(escaped)"
        end tell
        """
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error == nil { return }
        }
        // Fallback: at least make the command available.
        Clipboard.copy(command)
    }
}

/// Modal confirmations for actions that would start a stopped sandbox.
enum Confirm {
    /// Returns true when the user agrees (or when confirmation is not needed).
    @MainActor
    static func startStoppedSandbox(named name: String, reason: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = "Start “\(name)”?"
        alert.informativeText = "\(reason) will start this stopped sandbox."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Start")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
}

final class Notifier {
    static let shared = Notifier()
    private var authorized = false

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            self.authorized = granted
        }
    }

    func send(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
