import Foundation
import ManagedSettings
import UserNotifications

// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
//
// There is no public API to open the containing app directly from a Shield extension
// (confirmed unsupported by Apple DTS; tracked as FB17261679 / FB22696417 / FB15079668).
// The only documented workaround is scheduling a local notification and having the user
// tap *that* to launch the app — a notification tap is a fully public app-launch path.
class ShieldActionExtension: ShieldActionDelegate {
    static let mirrorGateNotificationID = "stoicMirrorGate"

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Deliberately does NOT dismiss the shield — it stays exactly as-is. The
            // notification tap is a separate, independent app-launch path that's the only
            // way into Stoic's Mirror Gate from here (see note above).
            scheduleMirrorGateNotification()
            completionHandler(.none)
        case .secondaryButtonPressed:
            // No secondary button is configured on the shield anymore; kept as a safe fallback.
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    private func scheduleMirrorGateNotification() {
        let isHebrew = UserDefaults(suiteName: "group.com.yonigolfor.Stoic")?.string(forKey: "preferredLanguage") == "he"

        let content = UNMutableNotificationContent()
        content.title = isHebrew ? "האפליקציה חסומה" : "This app is blocked"
        content.subtitle = isHebrew ? "לחץ כאן כדי לבקש רשות מחכמי הסטואים" : "Tap here to request permission from the Stoic Sages"
        content.sound = .default
        // Breaks through Focus/DND and renders as a prominent banner immediately,
        // rather than being silently grouped or delayed like a normal notification.
        content.interruptionLevel = .timeSensitive
        content.relevanceScore = 1.0

        let request = UNNotificationRequest(
            identifier: Self.mirrorGateNotificationID,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.05, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
