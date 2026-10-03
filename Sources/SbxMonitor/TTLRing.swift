import SwiftUI

/// Shared urgency classification for TTL display across the tray panel.
enum TTLUrgency {
    case unknown    // expiry not reported
    case expired    // at or past expiry
    case critical   // less than 30 minutes left
    case warning    // less than an hour left
    case healthy

    init(remaining: TimeInterval?) {
        guard let remaining else { self = .unknown; return }
        if remaining <= 0 { self = .expired }
        else if remaining < 1_800 { self = .critical }
        else if remaining < 3_600 { self = .warning }
        else { self = .healthy }
    }

    var color: Color {
        switch self {
        case .unknown: return .secondary
        case .expired, .critical: return .red
        case .warning: return .orange
        case .healthy: return .green
        }
    }
}

/// A live countdown with a draining progress ring. The ring fraction is
/// remaining ÷ (expires − created), so it drains at the sandbox's true burn
/// rate; without a creation time it drains across the final hour.
struct TTLRing: View {
    let expires: Date?
    let created: Date?
    var font: Font = .system(.caption, weight: .medium)

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = expires?.timeIntervalSince(context.date)
            let urgency = TTLUrgency(remaining: remaining)
            HStack(spacing: 5) {
                ring(fraction: fraction(remaining: remaining), urgency: urgency)
                    .help(expires.map { "Expires \(Fmt.absolute($0))" } ?? "No expiry reported")
                Text(label(remaining: remaining))
                    .font(font.monospacedDigit())
                    .foregroundStyle(labelColor(urgency))
            }
        }
    }

    private func ring(fraction: CGFloat, urgency: TTLUrgency) -> some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(urgency.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 18, height: 18)
        .animation(.easeInOut(duration: 0.5), value: fraction)
    }

    private func fraction(remaining: TimeInterval?) -> CGFloat {
        guard let remaining, remaining > 0, let expires else { return 0 }
        if let created, expires > created {
            return CGFloat(min(1, remaining / expires.timeIntervalSince(created)))
        }
        return CGFloat(min(1, remaining / 3_600))
    }

    private func label(remaining: TimeInterval?) -> String {
        guard let remaining else { return "—" }
        return Fmt.duration(Int(remaining))
    }

    private func labelColor(_ urgency: TTLUrgency) -> Color {
        switch urgency {
        case .healthy: return .secondary
        case .unknown: return .secondary.opacity(0.6)
        default: return urgency.color
        }
    }
}
