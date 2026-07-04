import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key: String {
        case hasCompletedOnboarding
        case morningNotificationTime
        case eveningNotificationTime
        case currentStreak
        case preferredLanguage
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
}
