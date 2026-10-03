import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var store: SandboxStore
    @Environment(\.openWindow) private var openWindow

    @State private var expandedIDs: Set<String> = []
    @State private var pendingStop: Sandbox?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let message = store.actionMessage {
                actionBanner(message)
            }
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 380)
        .task { store.start() }
        .task(id: store.actionMessage) { await autoClearActionMessage() }
        .confirmationDialog(
            "Stop \(pendingStop?.displayName ?? "sandbox")?",
            isPresented: Binding(
                get: { pendingStop != nil },
                set: { if !$0 { pendingStop = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Stop Sandbox") {
                if let sandbox = pendingStop { Task { await store.stop(sandbox) } }
                pendingStop = nil
            }
            Button("Cancel", role: .cancel) { pendingStop = nil }
        } message: {
            Text("State is preserved and compute billing stops. Resume with attach.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cloud Sandboxes")
                        .font(.system(.headline, weight: .semibold))
                    if !store.sandboxes.isEmpty {
                        statChips
                    }
                }
                Spacer()
                Button {
                    Task { await store.refresh() }
                } label: {
                    if store.isLoading {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.borderless)
                .help("Refresh now")

                SettingsLink {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .help("Settings")
            }
            if store.runningCount > 0 {
                FleetTTLBar(sandboxes: store.sandboxes)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var statChips: some View {
        HStack(spacing: 5) {
            if store.runningCount > 0 {
                StatChip(color: .green, label: "\(store.runningCount) running")
            }
            if store.stoppedCount > 0 {
                StatChip(color: .secondary, label: "\(store.stoppedCount) stopped")
            }
            if store.totalCPUs > 0 {
                StatChip(color: .blue, label: "\(store.totalCPUs) vCPU")
            }
            if store.totalMemoryMiB > 0 {
                StatChip(color: .orange, label: Fmt.memory(store.totalMemoryMiB))
            }
        }
    }

    private func actionBanner(_ message: String) -> some View {
        Label(message, systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundStyle(.green)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let error = store.errorMessage {
            VStack(alignment: .leading, spacing: 6) {
                Label("Could not load sandboxes", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.callout)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
        } else if store.sandboxes.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "shippingbox")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                Text(store.isLoading ? "Loading…" : "No cloud sandboxes")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        } else {
            VStack(spacing: 0) {
                if let urgent = store.mostUrgent, needsAttention(urgent) {
                    AttentionStrip(
                        sandbox: urgent,
                        onExtend: { Task { await store.extend(urgent, by: "30m") } },
                        onDetails: {
                            _ = withAnimation(.easeInOut(duration: 0.15)) { expandedIDs.insert(urgent.id) }
                        }
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    Divider()
                }
                if store.runningCount > 0 {
                    Text("BY TIME LEFT")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.top, 6)
                        .padding(.bottom, 2)
                }
                sandboxList
            }
            .animation(.easeInOut(duration: 0.2), value: store.mostUrgent?.id)
        }
    }

    private var sandboxList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.sandboxes) { sandbox in
                    TraySandboxRow(
                        sandbox: sandbox,
                        isExpanded: expandedIDs.contains(sandbox.id),
                        onToggle: { toggleExpanded(sandbox.id) },
                        onOpen: { openMain(sandbox.id) },
                        onTerminal: { openTerminal(sandbox.id) },
                        onExtend: { Task { await store.extend(sandbox, by: "30m") } },
                        onStop: { pendingStop = sandbox }
                    )
                    if sandbox.id != store.sandboxes.last?.id {
                        Divider().padding(.leading, 30)
                    }
                }
            }
        }
        .frame(maxHeight: 460)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            Button {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            } label: {
                Label("Open Dashboard", systemImage: "macwindow")
            }
            .buttonStyle(.borderless)
            Spacer()
            if let updated = store.lastUpdated {
                Text("Updated \(Fmt.relative(updated))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    /// Shows the strip when the most urgent sandbox is inside the user's
    /// configured warning window (or already expired).
    private func needsAttention(_ sandbox: Sandbox) -> Bool {
        guard let expires = sandbox.expiresDate else { return false }
        return expires.timeIntervalSinceNow < store.ttlWarningMinutes * 60
    }

    private func toggleExpanded(_ id: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if expandedIDs.contains(id) {
                expandedIDs.remove(id)
            } else {
                expandedIDs.insert(id)
            }
        }
    }

    private func autoClearActionMessage() async {
        guard store.actionMessage != nil else { return }
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        if !Task.isCancelled { store.actionMessage = nil }
    }

    private func openMain(_ id: String) {
        store.selectedID = id
        openWindow(id: "main")
        NSApp.activate(ignoringOtherApps: true)
    }

    private func openTerminal(_ id: String) {
        store.selectedID = id
        openWindow(id: "terminal", value: id)
        NSApp.activate(ignoringOtherApps: true)
    }
}
