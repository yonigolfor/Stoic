import UIKit
import UserNotifications

extension Notification.Name {
    static let stoicMirrorGateTapped = Notification.Name("stoicMirrorGateTapped")
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    /// Must match `ShieldActionExtension.mirrorGateNotificationID` in the StoicShieldAction
    /// target — extensions compile as a separate module, so this can't be a shared symbol.
    private static let mirrorGateNotificationID = "stoicMirrorGate"

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier == Self.mirrorGateNotificationID {
            // A live NotificationCenter post can be missed on a cold launch (SwiftUI's
            // `.onReceive` subscriber isn't attached yet when `didReceive` fires) — the
            // persisted flag is the reliable signal; StoicApp checks it once active.
            PersistenceService.shared.pendingMirrorGateTrigger = true
            NotificationCenter.default.post(name: .stoicMirrorGateTapped, object: nil)
        }
        completionHandler()
    }
}
