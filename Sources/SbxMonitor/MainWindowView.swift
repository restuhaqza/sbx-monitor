import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var store: SandboxStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            if let sandbox = store.selected {
                SandboxDetailView(sandbox: sandbox)
            } else {
                ContentUnavailableView(
                    "No sandbox selected",
                    systemImage: "shippingbox",
                    description: Text("Pick a cloud sandbox from the list, or create one with `sbx --cloud create`.")
                )
            }
        }
        .task { store.start() }
        .toolbar {
            ToolbarItemGroup {
                if let id = store.selectedID {
                    Button {
                        openWindow(id: "terminal", value: id)
                    } label: {
                        Label("Terminal", systemImage: "terminal")
                    }
                    .help("Open an embedded terminal for the selected sandbox")
                }
                if store.isLoading {
                    ProgressView().controlSize(.small)
                }
                Button {
                    Task { await store.refresh() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .help("Refresh now")
            }
        }
    }

    private var sidebar: some View {
        List(selection: $store.selectedID) {
            Section {
                if store.sandboxes.isEmpty {
                    Text(store.isLoading ? "Loading…" : "No cloud sandboxes")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.sandboxes) { sandbox in
                        SandboxRow(sandbox: sandbox)
                            .tag(sandbox.id)
                    }
                }
            } header: {
                HStack {
                    Text("Cloud Sandboxes")
                    Spacer()
                    if !store.sandboxes.isEmpty {
                        Text("\(store.runningCount) running")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 380)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                if let error = store.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .lineLimit(3)
                } else if let updated = store.lastUpdated {
                    Label("Updated \(Fmt.relative(updated))", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.bar)
        }
    }
}
