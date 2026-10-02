import SwiftUI

struct SandboxDetailView: View {
    let sandbox: Sandbox
    @EnvironmentObject var store: SandboxStore
    @Environment(\.openWindow) private var openWindow

    @State private var confirmRemove = false
    @State private var confirmStop = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                infoCard
                if sandbox.hasPorts { portsCard }
                actionsCard
            }
            .padding(24)
            .frame(maxWidth: 760, alignment: .leading)
        }
        .navigationTitle(sandbox.displayName)
        .confirmationDialog("Remove \(sandbox.displayName)?", isPresented: $confirmRemove, titleVisibility: .visible) {
            Button("Remove Sandbox", role: .destructive) {
                Task { await store.remove(sandbox) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes the sandbox and everything inside it. This cannot be undone.")
        }
        .confirmationDialog("Stop \(sandbox.displayName)?", isPresented: $confirmStop, titleVisibility: .visible) {
            Button("Stop Sandbox") {
                Task { await store.stop(sandbox) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("State is preserved and compute billing stops. Resume with attach.")
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 34))
                .foregroundStyle(sandbox.isRunning ? Color.green : Color.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(sandbox.displayName)
                    .font(.system(.title, weight: .semibold))
                HStack(spacing: 8) {
                    statusPill
                    if let agent = sandbox.agent, !agent.isEmpty {
                        Text(agent).font(.callout).foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            if store.acting.contains(sandbox.id) {
                ProgressView().controlSize(.small)
            }
        }
    }

    private var statusPill: some View {
        Text(sandbox.status.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background((sandbox.isRunning ? Color.green : Color.gray).opacity(0.18))
            .foregroundStyle(sandbox.isRunning ? Color.green : Color.secondary)
            .clipShape(Capsule())
    }

    private var infoCard: some View {
        GroupBox("Runtime") {
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 10) {
                GridRow { infoLabel("Sandbox ID"); Text(sandbox.id).font(.system(.body, design: .monospaced)).textSelection(.enabled) }
                GridRow { infoLabel("Backend"); Text("Cloud (Docker-managed)") }
                GridRow { infoLabel("Resources"); Text("\(sandbox.cpus ?? 0) vCPU · \(Fmt.memory(sandbox.memoryMiB))") }
                if let image = sandbox.image { GridRow { infoLabel("Image"); Text(image).font(.system(.callout, design: .monospaced)).textSelection(.enabled) } }
                GridRow { infoLabel("Created"); Text(Fmt.absolute(sandbox.createdDate)) }
                GridRow {
                    infoLabel("Expires")
                    HStack(spacing: 8) {
                        TTLCountdown(date: sandbox.expiresDate, font: .body)
                        Text("(\(Fmt.absolute(sandbox.expiresDate)))").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var portsCard: some View {
        GroupBox("Exposed ports") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sandbox.ports ?? []) { port in
                    HStack(spacing: 10) {
                        Text(port.label)
                            .font(.system(.callout, design: .monospaced))
                            .frame(width: 70, alignment: .leading)
                        if let url = port.url {
                            Text(url)
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .textSelection(.enabled)
                            Spacer()
                            Button("Open") { Shell.openURL(url) }
                            Button("Copy") { Clipboard.copy(url) }
                        } else {
                            Text("host port \(port.hostPort ?? 0)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        Button("Unpublish", role: .destructive) {
                            Task { await store.unpublish(sandbox, port: port.sandboxPort) }
                        }
                    }
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionsCard: some View {
        GroupBox("Actions") {
            HStack(spacing: 10) {
                Button {
                    openWindow(id: "terminal", value: sandbox.id)
                } label: {
                    Label("Open Terminal", systemImage: "terminal")
                }
                Button {
                    Shell.openInTerminal("sbx --cloud attach \(sandbox.id)")
                } label: {
                    Label("External Terminal", systemImage: "terminal.fill")
                }
                Button {
                    let command = "sbx --cloud attach \(sandbox.id)"
                    Clipboard.copy(command)
                    store.actionMessage = "Attach command copied"
                } label: {
                    Label("Copy attach command", systemImage: "doc.on.doc")
                }
                Menu {
                    Button("+15m") { Task { await store.extend(sandbox, by: "15m") } }
                    Button("+30m") { Task { await store.extend(sandbox, by: "30m") } }
                    Button("+1h") { Task { await store.extend(sandbox, by: "1h") } }
                    Button("+2h") { Task { await store.extend(sandbox, by: "2h") } }
                } label: {
                    Label("Extend TTL", systemImage: "clock.arrow.circlepath")
                }
                .fixedSize()
                Spacer()
                Button {
                    confirmStop = true
                } label: {
                    Label("Stop", systemImage: "stop.circle")
                }
                .disabled(!sandbox.isRunning)
                Button(role: .destructive) {
                    confirmRemove = true
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func infoLabel(_ text: String) -> some View {
        Text(text).foregroundStyle(.secondary).frame(width: 90, alignment: .leading)
    }
}
