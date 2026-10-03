import SwiftUI

/// Pinned warning shown when the most urgent running sandbox crosses the TTL
/// warning threshold. The reflex action — extend by 30 minutes — is one click.
struct AttentionStrip: View {
    let sandbox: Sandbox
    var onExtend: () -> Void
    var onDetails: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = sandbox.expiresDate?.timeIntervalSince(context.date)
            let urgency = TTLUrgency(remaining: remaining)
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(urgency.color)
                message(remaining)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundStyle(Color.primary.opacity(0.85))
                Spacer(minLength: 6)
                Button("+30m", action: onExtend)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                Button("Details", action: onDetails)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            .tint(urgency.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 8).fill(urgency.color.opacity(0.13)))
            .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(urgency.color.opacity(0.35)))
        }
    }

    private func message(_ remaining: TimeInterval?) -> Text {
        let name = Text(sandbox.displayName).fontWeight(.semibold)
        guard let remaining else { return name + Text(" · no expiry reported") }
        if remaining <= 0 { return name + Text(" expired") }
        return name + Text("  expires in \(Fmt.duration(Int(remaining)))")
    }
}
