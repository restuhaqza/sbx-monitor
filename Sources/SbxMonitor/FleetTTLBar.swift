import SwiftUI

/// A stacked bar where each segment is a running sandbox, width proportional to
/// its remaining TTL (clamped to a 2-hour window) — the fleet's expiry shape at
/// a glance. Segments are ordered most-urgent-first.
struct FleetTTLBar: View {
    let sandboxes: [Sandbox]

    private let window: TimeInterval = 2 * 3_600

    private struct Segment: Identifiable {
        let sandbox: Sandbox
        let remaining: TimeInterval
        var id: String { sandbox.id }
    }

    private var segments: [Segment] {
        sandboxes
            .filter(\.isRunning)
            .compactMap { sandbox -> Segment? in
                guard let expires = sandbox.expiresDate else { return nil }
                return Segment(sandbox: sandbox, remaining: expires.timeIntervalSinceNow)
            }
            .sorted { $0.remaining < $1.remaining }
    }

    var body: some View {
        let segments = segments
        VStack(alignment: .leading, spacing: 6) {
            Text("FLEET TTL · NEXT 2H")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(.tertiary)
            bar(segments)
            legend(segments)
        }
    }

    private func bar(_ segments: [Segment]) -> some View {
        GeometryReader { geo in
            let fractions = segments.map { segment -> CGFloat in
                guard segment.remaining > 0 else { return 0 }
                return min(1, CGFloat(segment.remaining / window))
            }
            // If everything fits inside the window, leave the rest as empty
            // track; otherwise scale down so the bar stays full but relative
            // proportions are preserved.
            let total = fractions.reduce(0, +)
            let scale = total > 0 ? min(1, 1 / total) : 0

            HStack(spacing: 2) {
                ForEach(Array(segments.enumerated()), id: \.element.id) { index, segment in
                    // Expired sandboxes still get a minimal visible sliver.
                    let fraction = max(0.02, fractions[index] * scale)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(TTLUrgency(remaining: segment.remaining).color.opacity(0.85))
                        .frame(width: geo.size.width * fraction)
                        .help("\(segment.sandbox.displayName) — \(Fmt.ttl(segment.sandbox.expiresDate)) left")
                }
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.05))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 8)
    }

    private struct LegendEntry: Identifiable {
        let name: String
        let detail: String
        let color: Color
        var id: String { name }
    }

    private func legend(_ segments: [Segment]) -> some View {
        let entries: [LegendEntry] = {
            var entries: [LegendEntry] = []
            let urgent = segments.filter { $0.remaining > 0 && $0.remaining < 3_600 }.prefix(3)
            for segment in urgent {
                entries.append(LegendEntry(
                    name: segment.sandbox.displayName,
                    detail: Fmt.duration(Int(segment.remaining)),
                    color: TTLUrgency(remaining: segment.remaining).color
                ))
            }
            let rest = segments.count - urgent.count
            if rest > 0 {
                entries.append(LegendEntry(name: "+\(rest) more", detail: "≥ 1h", color: .green))
            }
            if entries.isEmpty, let first = segments.first {
                entries.append(LegendEntry(
                    name: "\(segments.count) running",
                    detail: "next expiry \(Fmt.duration(Int(max(0, first.remaining))))",
                    color: .green
                ))
            }
            return entries
        }()

        return HStack(spacing: 10) {
            ForEach(entries) { entry in
                HStack(spacing: 4) {
                    Circle()
                        .fill(entry.color.opacity(0.85))
                        .frame(width: 6, height: 6)
                    Text(entry.name)
                    Text(entry.detail)
                        .foregroundStyle(.tertiary)
                }
                .font(.system(size: 9.5, weight: .medium).monospacedDigit())
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
        }
    }
}

/// Compact header chips: one fact per shape, each with its own color.
struct StatChip: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.9))
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 10.5, weight: .semibold).monospacedDigit())
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 2.5)
        .background(Capsule().fill(Color.primary.opacity(0.06)))
        .foregroundStyle(.secondary)
        .fixedSize()
    }
}
