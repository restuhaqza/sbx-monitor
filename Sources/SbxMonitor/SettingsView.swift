import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: SandboxStore
    @StateObject private var login = LaunchAtLogin()
    @State private var pathOverride: String = SbxClient.shared.overridePath ?? ""
    @State private var version: String = "—"

    private let intervals: [(String, Double)] = [
        ("5 seconds", 5), ("10 seconds", 10), ("15 seconds", 15),
        ("30 seconds", 30), ("1 minute", 60)
    ]

    var body: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: Binding(
                    get: { login.isEnabled },
                    set: { login.setEnabled($0) }
                ))
                if login.needsApproval {
                    HStack {
                        Text("Approval required in System Settings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Open Login Items") { login.openLoginItemsSettings() }
                    }
                }
                if let error = login.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                Text("Keep Sbx Monitor in a stable location (e.g. /Applications) so the login item keeps working.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Section("Monitoring") {
                Toggle("Auto-refresh", isOn: $store.autoRefresh)
                Picker("Refresh every", selection: $store.refreshInterval) {
                    ForEach(intervals, id: \.1) { Text($0.0).tag($0.1) }
                }
                .onChange(of: store.refreshInterval) { _, _ in store.restartTimer() }
            }

            Section("Notifications") {
                Toggle("Notify when a sandbox expires soon", isOn: $store.notificationsEnabled)
                Picker("Warn before", selection: $store.ttlWarningMinutes) {
                    Text("1 minute").tag(1.0)
                    Text("5 minutes").tag(5.0)
                    Text("15 minutes").tag(15.0)
                    Text("30 minutes").tag(30.0)
                }
                .disabled(!store.notificationsEnabled)
            }

            Section("sbx CLI") {
                LabeledContent("Detected path") {
                    Text(store.detectedSbxPath ?? "not found")
                        .foregroundStyle(store.detectedSbxPath == nil ? .red : .secondary)
                        .textSelection(.enabled)
                }
                TextField("Override path (optional)", text: $pathOverride)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { SbxClient.shared.overridePath = pathOverride }
                LabeledContent("Version", value: version)
                HStack {
                    Button("Apply") { SbxClient.shared.overridePath = pathOverride }
                    Button("Clear override") { pathOverride = ""; SbxClient.shared.overridePath = "" }
                    Spacer()
                    Button("Test connection") {
                        Task {
                            await store.refresh()
                            version = (try? SbxClient.shared.version())??.client?.version ?? "—"
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .task {
            version = (try? SbxClient.shared.version())??.client?.version ?? "—"
        }
    }
}
