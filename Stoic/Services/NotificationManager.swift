import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleMorningNotification(timeString: String) {
        schedule(
            identifier: "marcus.morning",
            title: String(localized: "notification.morning.title"),
            body: String(localized: "notification.morning.body"),
            timeString: timeString
        )
    }

    func scheduleEveningNotification(timeString: String) {
        schedule(
            identifier: "marcus.evening",
            title: String(localized: "notification.evening.title"),
            body: String(localized: "notification.evening.body"),
            timeString: timeString
        )
    }

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func schedule(identifier: String, title: String, body: String, timeString: String) {
        guard let components = timeComponents(from: timeString) else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var trigger = DateComponents()
        trigger.hour = components.hour
        trigger.minute = components.minute

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func timeComponents(from string: String) -> (hour: Int, minute: Int)? {
        let parts = string.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}
