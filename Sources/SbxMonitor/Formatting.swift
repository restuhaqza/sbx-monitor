import Foundation
import SwiftUI

enum Fmt {
    static func memory(_ mib: Int?) -> String {
        guard let mib else { return "—" }
        if mib >= 1024 {
            let gib = Double(mib) / 1024.0
            return gib.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(gib)) GiB" : String(format: "%.1f GiB", gib)
        }
        return "\(mib) MiB"
    }

    static func duration(_ seconds: Int) -> String {
        if seconds <= 0 { return "expired" }
        let d = seconds / 86_400
        let h = (seconds % 86_400) / 3_600
        let m = (seconds % 3_600) / 60
        let s = seconds % 60
        if d > 0 { return "\(d)d \(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }

    static func ttl(_ date: Date?, now: Date = Date()) -> String {
        guard let date else { return "—" }
        return duration(Int(date.timeIntervalSince(now)))
    }

    static func absolute(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    /// Compact date/time, e.g. "Oct 3, 09:12".
    static func short(_ date: Date?) -> String {
        guard let date else { return "—" }
        let f = DateFormatter()
        f.dateFormat = "MMM d, HH:mm"
        return f.string(from: date)
    }

    static func relative(_ date: Date?, now: Date = Date()) -> String {
        guard let date else { return "—" }
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: now)
    }
}

/// A live countdown to a date, re-rendering once per second.
struct TTLCountdown: View {
    let date: Date?
    var font: Font = .body
    var monospaced = true

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let text = Fmt.ttl(date, now: context.date)
            Text(text)
                .font(monospaced ? font.monospacedDigit() : font)
                .foregroundStyle(color(for: date, now: context.date))
        }
    }

    private func color(for date: Date?, now: Date) -> Color {
        guard let date else { return .secondary }
        let remaining = date.timeIntervalSince(now)
        if remaining <= 0 { return .red }
        if remaining < 300 { return .orange }
        if remaining < 1800 { return .yellow }
        return .secondary
    }
}
