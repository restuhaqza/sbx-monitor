import SwiftUI

struct StatusDot: View {
    let running: Bool
    var body: some View {
        Circle()
            .fill(running ? Color.green : Color.secondary)
            .frame(width: 8, height: 8)
            .overlay(Circle().stroke(.black.opacity(0.08), lineWidth: 0.5))
    }
}

struct SandboxRow: View {
    let sandbox: Sandbox

    var body: some View {
        HStack(spacing: 10) {
            StatusDot(running: sandbox.isRunning)
            VStack(alignment: .leading, spacing: 2) {
                Text(sandbox.displayName)
                    .font(.system(.body, weight: .medium))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(sandbox.agent?.isEmpty == false ? sandbox.agent! : "shell")
                    Text("·")
                    Text("\(sandbox.cpus ?? 0) vCPU / \(Fmt.memory(sandbox.memoryMiB))")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                TTLCountdown(date: sandbox.expiresDate, font: .system(.callout, weight: .semibold))
                if sandbox.hasPorts {
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 3)
    }
}
