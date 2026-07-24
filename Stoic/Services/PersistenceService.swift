import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    /// App Group suite so the Shield/DeviceActivity extensions can read the same values.
    private let defaults = UserDefaults(suiteName: "group.com.yonigolfor.Stoic") ?? .standard

    private enum Key: String {
        case hasCompletedOnboarding
        case morningNotificationTime
        case eveningNotificationTime
        case currentStreak
        case preferredLanguage
        case selectedFocusAppsRaw
        case lastMirrorGateGraceGrantedAt
        case focusVictoriesCount
        case focusVictoriesWeekCount
        case focusVictoriesWeekStart
        case focusStreakDays
        case lastFocusVictoryDate
        case pendingMirrorGateTrigger
        case lastGraceMonitoringError
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding.rawValue) }
    }

    var morningNotificationTime: String {
        get { defaults.string(forKey: Key.morningNotificationTime.rawValue) ?? "08:00" }
        set { defaults.set(newValue, forKey: Key.morningNotificationTime.rawValue) }
    }

    var eveningNotificationTime: String {
        get { defaults.string(forKey: Key.eveningNotificationTime.rawValue) ?? "20:00" }
        set { defaults.set(newValue, forKey: Key.eveningNotificationTime.rawValue) }
    }

    var currentStreak: Int {
        get { defaults.integer(forKey: Key.currentStreak.rawValue) }
        set { defaults.set(newValue, forKey: Key.currentStreak.rawValue) }
    }

    var preferredLanguage: String? {
        get { defaults.string(forKey: Key.preferredLanguage.rawValue) }
        set { defaults.set(newValue, forKey: Key.preferredLanguage.rawValue) }
    }

    // MARK: - Friction Gate

    /// Encoded `FamilyActivitySelection` chosen in onboarding. Key name is also read directly
    /// (by string literal, not this class) from `StoicActivityMonitor` — keep both in sync.
    var selectedFocusAppsRaw: Data? {
        get { defaults.data(forKey: Key.selectedFocusAppsRaw.rawValue) }
        set { defaults.set(newValue, forKey: Key.selectedFocusAppsRaw.rawValue) }
    }

    var lastMirrorGateGraceGrantedAt: Date? {
        get { defaults.object(forKey: Key.lastMirrorGateGraceGrantedAt.rawValue) as? Date }
        set { defaults.set(newValue, forKey: Key.lastMirrorGateGraceGrantedAt.rawValue) }
    }

    /// Diagnostic: `DeviceActivityCenter.startMonitoring`'s thrown error, if the last grace
    /// period request failed to register (e.g. `MonitoringError.intervalTooShort`). `nil` means
    /// the last attempt registered successfully.
    var lastGraceMonitoringError: String? {
        get { defaults.string(forKey: Key.lastGraceMonitoringError.rawValue) }
        set { defaults.set(newValue, forKey: Key.lastGraceMonitoringError.rawValue) }
    }

    /// Set by `AppDelegate` when the Mirror Gate notification is tapped. `StoicApp` checks
    /// this once the scene is actually `.active` rather than relying solely on a live
    /// NotificationCenter broadcast, which can be missed on a cold launch (the SwiftUI
    /// `.onReceive` subscriber isn't attached yet at the moment `didReceive` fires).
    var pendingMirrorGateTrigger: Bool {
        get { defaults.bool(forKey: Key.pendingMirrorGateTrigger.rawValue) }
        set { defaults.set(newValue, forKey: Key.pendingMirrorGateTrigger.rawValue) }
    }

    // MARK: - Focus Victories

    static let weeklyFocusGoal = 10

    var focusVictoriesCount: Int {
        get { defaults.integer(forKey: Key.focusVictoriesCount.rawValue) }
        set { defaults.set(newValue, forKey: Key.focusVictoriesCount.rawValue) }
    }

    var focusVictoriesWeekCount: Int {
        get { defaults.integer(forKey: Key.focusVictoriesWeekCount.rawValue) }
        set { defaults.set(newValue, forKey: Key.focusVictoriesWeekCount.rawValue) }
    }

    var focusStreakDays: Int {
        get { defaults.integer(forKey: Key.focusStreakDays.rawValue) }
        set { defaults.set(newValue, forKey: Key.focusStreakDays.rawValue) }
    }

    private var focusVictoriesWeekStart: Date? {
        get { defaults.object(forKey: Key.focusVictoriesWeekStart.rawValue) as? Date }
        set { defaults.set(newValue, forKey: Key.focusVictoriesWeekStart.rawValue) }
    }

    private var lastFocusVictoryDate: Date? {
        get { defaults.object(forKey: Key.lastFocusVictoryDate.rawValue) as? Date }
        set { defaults.set(newValue, forKey: Key.lastFocusVictoryDate.rawValue) }
    }

    /// Call when the user chooses "Step Back" in the Mirror Gate. Rolls the weekly
    /// bucket over on a new calendar week and extends/resets the consecutive-day streak.
    @discardableResult
    func recordFocusVictory() -> (total: Int, thisWeek: Int, streak: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let weekStart = focusVictoriesWeekStart, calendar.isDate(weekStart, equalTo: today, toGranularity: .weekOfYear) {
            focusVictoriesWeekCount += 1
        } else {
            focusVictoriesWeekStart = today
            focusVictoriesWeekCount = 1
        }

        if let lastDate = lastFocusVictoryDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if calendar.isDate(lastDay, inSameDayAs: today) {
                // Already counted today — streak unchanged.
            } else if let dayAfterLast = calendar.date(byAdding: .day, value: 1, to: lastDay), calendar.isDate(dayAfterLast, inSameDayAs: today) {
                focusStreakDays += 1
            } else {
                focusStreakDays = 1
            }
        } else {
            focusStreakDays = 1
        }

        lastFocusVictoryDate = today
        focusVictoriesCount += 1

        return (focusVictoriesCount, focusVictoriesWeekCount, focusStreakDays)
    }

    // MARK: - Shuffle Queue

    private func queueKey(for category: String) -> String { "quoteQueue_\(category)" }

    func quoteQueue(for category: String) -> [String] {
        defaults.stringArray(forKey: queueKey(for: category)) ?? []
    }

    func setQuoteQueue(_ queue: [String], for category: String) {
        defaults.set(queue, forKey: queueKey(for: category))
    }

    func clearAllQuoteQueues() {
        let prefix = "quoteQueue_"
        defaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(prefix) }
            .forEach { defaults.removeObject(forKey: $0) }
        lastPickedQuoteId = nil
        lastPickedDateKey = nil
    }

    // MARK: - Daily Quote Cache

    var lastPickedQuoteId: String? {
        get { defaults.string(forKey: "lastPickedQuoteId") }
        set { defaults.set(newValue, forKey: "lastPickedQuoteId") }
    }

    var lastPickedDateKey: String? {
        get { defaults.string(forKey: "lastPickedDateKey") }
        set { defaults.set(newValue, forKey: "lastPickedDateKey") }
    }
}
