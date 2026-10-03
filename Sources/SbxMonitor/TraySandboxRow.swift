import SwiftUI

/// A tray-dropdown row that expands in place to reveal sandbox details,
/// exposed ports, and quick actions. Collapsed, it leads with urgency: a TTL
/// ring for running sandboxes, an attach affordance for stopped ones.
struct TraySandboxRow: View {
    let sandbox: Sandbox
    let isExpanded: Bool
    var onToggle: () -> Void
    var onOpen: () -> Void
    var onTerminal: () -> Void
    var onExtend: () -> Void
    var onStop: () -> Void

    @EnvironmentObject private var store: SandboxStore
    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Button(action: onOpen) {
                    HStack(spacing: 9) {
                        StatusDot(running: sandbox.isRunning)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sandbox.displayName)
                                .font(.system(.body, weight: .medium))
                                .lineLimit(1)
                            Text(metaLine)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 8)

                trailing
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .onHover { hovering = $0 }

            if isExpanded {
                detail
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .contextMenu {
            Button("Open Terminal") { onTerminal() }
            Button("Open Dashboard") { onOpen() }
            Button("Extend TTL +30m") { onExtend() }
            Button(isExpanded ? "Hide Details" : "Show Details") { onToggle() }
        }
    }

    // MARK: - Collapsed row trailing side

    private var trailing: some View {
        HStack(spacing: 7) {
            if sandbox.hasPorts {
                Image(systemName: "globe")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .help("Has exposed ports")
            }

            if sandbox.isRunning {
                TTLRing(expires: sandbox.expiresDate, created: sandbox.createdDate)
            } else {
                Button {
                    if store.willStartStopped(sandbox),
                       !Confirm.startStoppedSandbox(named: sandbox.displayName, reason: "Attaching") {
                        return
                    }
                    Shell.openInTerminal("sbx --cloud attach \(sandbox.id)")
                    store.actionMessage = "Attach opened in Terminal"
                } label: {
                    Text("attach?")
                        .font(.system(size: 10.5, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Resume this sandbox with sbx --cloud attach")
            }

            hoverRail
            chevron
        }
        .animation(.easeInOut(duration: 0.15), value: hovering)
    }

    /// Quick actions that fade in on hover — an accelerator, not the only path
    /// (the context menu always carries the same commands).
    private var hoverRail: some View {
        HStack(spacing: 4) {
            Button(action: onExtend) {
                Text("+30m")
                    .font(.system(size: 10.5, weight: .medium))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .help("Extend TTL by 30 minutes")

            Button(action: onTerminal) {
                Image(systemName: "terminal")
                    .font(.caption)
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            .help("Open terminal")
        }
        .opacity(hovering ? 1 : 0)
        .allowsHitTesting(hovering)
    }

    private var chevron: some View {
        Button(action: onToggle) {
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .help(isExpanded ? "Hide details" : "Show details")
    }

    private var metaLine: String {
        if !sandbox.isRunning { return "stopped · state preserved" }
        let agent = sandbox.agent?.isEmpty == false ? sandbox.agent! : "shell"
        return "\(agent) · \(sandbox.cpus ?? 0) vCPU / \(Fmt.memory(sandbox.memoryMiB))"
    }

    // MARK: - Expanded detail

    private var detail: some View {
        VStack(alignment: .leading, spacing: 10) {
            infoGrid
            if sandbox.hasPorts { portsSection }
            Divider()
            actions
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.045)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.primary.opacity(0.07)))
    }

    private var infoGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 5) {
            if let image = sandbox.image {
                GridRow {
                    detailLabel("Image")
                    Text(image)
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .help(image)
                }
            }
            GridRow {
                detailLabel("Created")
                Text(createdText)
                    .font(.caption)
                    .lineLimit(1)
            }
            GridRow {
                detailLabel("Expires")
                HStack(spacing: 5) {
                    TTLCountdown(date: sandbox.expiresDate, font: .system(.caption, weight: .medium))
                    Text("· \(Fmt.short(sandbox.expiresDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            GridRow {
                detailLabel("ID")
                HStack(spacing: 4) {
                    Text(sandbox.id)
                        .font(.system(.caption, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .help(sandbox.id)
                    copyButton(sandbox.id, confirmation: "Sandbox ID copied")
                }
            }
        }
    }

    private var portsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ports")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(sandbox.ports ?? []) { port in
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text(port.label)
                        .font(.system(.caption2, design: .monospaced))
                    if let url = port.url {
                        Text(url)
                            .font(.caption2)
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(url)
                        Spacer(minLength: 4)
                        Button {
                            Shell.openURL(url)
                        } label: {
                            Image(systemName: "arrow.up.forward.app")
                        }
                        .buttonStyle(.borderless)
                        .help("Open in browser")
                        copyButton(url, confirmation: "URL copied")
                    } else {
                        Text("host port \(port.hostPort.map(String.init) ?? "?")")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }

    private var actions: some View {
        HStack(spacing: 6) {
            Button {
                onTerminal()
            } label: {
                Label("Terminal", systemImage: "terminal")
            }
            .help("Open an embedded terminal")

            Menu {
                Button("+15m") { Task { await store.extend(sandbox, by: "15m") } }
                Button("+30m") { Task { await store.extend(sandbox, by: "30m") } }
                Button("+1h") { Task { await store.extend(sandbox, by: "1h") } }
                Button("+2h") { Task { await store.extend(sandbox, by: "2h") } }
            } label: {
                Label("Extend", systemImage: "clock.arrow.circlepath")
            }
            .fixedSize()
            .help("Extend the sandbox TTL")

            Button {
                Clipboard.copy("sbx --cloud attach \(sandbox.id)")
                store.actionMessage = "Attach command copied"
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .help("Copy attach command")

            Spacer(minLength: 8)

            if store.acting.contains(sandbox.id) {
                ProgressView().controlSize(.small)
            }
            Button {
                onStop()
            } label: {
                Label("Stop", systemImage: "stop.circle")
            }
            .tint(.orange)
            .disabled(!sandbox.isRunning)
        }
        .controlSize(.small)
    }

    // MARK: - Helpers

    private func detailLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(width: 48, alignment: .leading)
    }

    private func copyButton(_ value: String, confirmation: String) -> some View {
        Button {
            Clipboard.copy(value)
            store.actionMessage = confirmation
        } label: {
            Image(systemName: "doc.on.doc")
                .font(.caption2)
        }
        .buttonStyle(.borderless)
        .help("Copy")
    }

    private var createdText: String {
        guard let created = sandbox.createdDate else { return "—" }
        return "\(Fmt.short(created)) · \(Fmt.relative(created))"
    }
}
