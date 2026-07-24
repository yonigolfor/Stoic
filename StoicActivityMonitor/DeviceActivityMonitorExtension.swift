import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
// `graceActivityName` here must match `ScreenTimeGateService.graceActivityName` in the main app —
// extensions compile as a separate module, so this can't be a shared symbol.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let graceActivityName = DeviceActivityName("mirrorGateGrace")

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity == graceActivityName else { return }
        reapplyShield()
    }

    private func reapplyShield() {
        guard let defaults = UserDefaults(suiteName: "group.com.yonigolfor.Stoic"),
              let data = defaults.data(forKey: "selectedFocusAppsRaw"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else { return }

        ManagedSettingsStore().shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens
    }
}
