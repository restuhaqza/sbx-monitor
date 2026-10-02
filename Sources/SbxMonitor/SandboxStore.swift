import Foundation
import Combine

@MainActor
final class SandboxStore: ObservableObject {
    @Published private(set) var sandboxes: [Sandbox] = []
    @Published private(set) var isLoading = false
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?
    @Published var actionMessage: String?
    @Published var selectedID: String?
    @Published var acting: Set<String> = []

    @Published var autoRefresh: Bool {
        didSet { UserDefaults.standard.set(autoRefresh, forKey: "autoRefresh") }
    }
    @Published var refreshInterval: Double {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval") }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    @Published var ttlWarningMinutes: Double {
        didSet { UserDefaults.standard.set(ttlWarningMinutes, forKey: "ttlWarningMinutes") }
    }

    private let client = SbxClient.shared
    private var timer: Timer?
    private var started = false
    private var notified: Set<String> = []

    var runningCount: Int { sandboxes.filter(\.isRunning).count }
    var selected: Sandbox? {
        guard let selectedID else { return nil }
        return sandboxes.first { $0.id == selectedID }
    }
    var detectedSbxPath: String? { client.locate() }

    init() {
        let defaults = UserDefaults.standard
        autoRefresh = defaults.object(forKey: "autoRefresh") as? Bool ?? true
        refreshInterval = defaults.object(forKey: "refreshInterval") as? Double ?? 15
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? true
        ttlWarningMinutes = defaults.object(forKey: "ttlWarningMinutes") as? Double ?? 5
    }

    func start() {
        guard !started else { return }
        started = true
        if notificationsEnabled { Notifier.shared.requestAuthorization() }
        Task { await refresh() }
        scheduleTimer()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: max(3, refreshInterval), repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                guard self.autoRefresh else { return }
                await self.refresh()
            }
        }
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await Task.detached(priority: .userInitiated) {
                try SbxClient.shared.listCloudSandboxes()
            }.value
            sandboxes = fetched.sorted { a, b in
                if a.isRunning != b.isRunning { return a.isRunning }
                return a.displayName.localizedCaseInsensitiveCompare(b.displayName) == .orderedAscending
            }
            errorMessage = nil
            lastUpdated = Date()
            if selectedID == nil { selectedID = sandboxes.first?.id }
            if let selectedID, !sandboxes.contains(where: { $0.id == selectedID }) { self.selectedID = sandboxes.first?.id }
            evaluateNotifications()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restartTimer() { scheduleTimer() }

    // MARK: - Actions

    func stop(_ sandbox: Sandbox) async {
        await perform(sandbox, "Stopped") { try SbxClient.shared.stop(sandbox.id) }
    }

    func remove(_ sandbox: Sandbox) async {
        await perform(sandbox, "Removed") { try SbxClient.shared.remove(sandbox.id) }
        if selectedID == sandbox.id { selectedID = nil }
    }

    func extend(_ sandbox: Sandbox, by duration: String = "30m") async {
        await perform(sandbox, "Extended \(duration)") { try SbxClient.shared.extendTTL(sandbox.id, by: duration) }
    }

    func unpublish(_ sandbox: Sandbox, port: Int) async {
        await perform(sandbox, "Unpublished \(port)") { try SbxClient.shared.unpublish(sandbox.id, port: port) }
    }

    private func perform(_ sandbox: Sandbox, _ label: String, _ work: @escaping () throws -> Void) async {
        acting.insert(sandbox.id)
        defer { acting.remove(sandbox.id) }
        do {
            try await Task.detached(priority: .userInitiated) { try work() }.value
            actionMessage = "\(label) \(sandbox.displayName)"
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Notifications

    private func evaluateNotifications() {
        guard notificationsEnabled else { return }
        let threshold = ttlWarningMinutes * 60
        for sandbox in sandboxes {
            guard let expires = sandbox.expiresDate else { continue }
            let remaining = expires.timeIntervalSinceNow
            let key = "\(sandbox.id)@\(Int(expires.timeIntervalSince1970))"
            if remaining > 0, remaining <= threshold, !notified.contains(key) {
                notified.insert(key)
                Notifier.shared.send(
                    title: "\(sandbox.displayName) expires soon",
                    body: "\(Fmt.ttl(expires)) left before this cloud sandbox expires."
                )
            }
        }
    }
}
