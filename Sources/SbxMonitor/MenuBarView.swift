import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var store: SandboxStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            content
            Divider()
            footer
        }
        .frame(width: 380)
        .task { store.start() }
    }

    private var header: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Cloud Sandboxes")
                    .font(.system(.headline, weight: .semibold))
                Text(store.runningCount > 0 ? "\(store.runningCount) running" : "none running")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

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
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.sandboxes) { sandbox in
                        HStack(spacing: 4) {
                            Button {
                                openMain(sandbox.id)
                            } label: {
                                SandboxRow(sandbox: sandbox)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            Button {
                                openTerminal(sandbox.id)
                            } label: {
                                Image(systemName: "terminal")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.borderless)
                            .help("Open terminal")
                        }
                        .padding(.horizontal, 12)
                        .contextMenu {
                            Button("Open Terminal") { openTerminal(sandbox.id) }
                            Button("Open Dashboard") { openMain(sandbox.id) }
                        }
                        if sandbox.id != store.sandboxes.last?.id {
                            Divider().padding(.leading, 30)
                        }
                    }
                }
            }
            .frame(maxHeight: 340)
        }
    }

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
