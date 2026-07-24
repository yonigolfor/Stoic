import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Grants temporary passage through the Friction Gate.
protocol ScreenTimeGateServicing {
    func grantGracePeriod(minutes: Int)
}

/// Used in SwiftUI Previews / anywhere the real Screen Time framework shouldn't run.
struct NoopScreenTimeGateService: ScreenTimeGateServicing {
    func grantGracePeriod(minutes: Int) {
        PersistenceService.shared.lastMirrorGateGraceGrantedAt = Date()
    }
}

/// Real Phase 2 implementation: lifts the shield immediately, then schedules
/// `StoicActivityMonitor` (via `DeviceActivitySchedule`) to re-apply it once `minutes`
/// have elapsed from the moment of the tap — a fixed wall-clock window, not usage time.
struct ScreenTimeGateService: ScreenTimeGateServicing {
    static let graceActivityName = DeviceActivityName("mirrorGateGrace")

    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()

    func grantGracePeriod(minutes: Int) {
        store.shield.applications = nil

        let now = Date()
        let end = Calendar.current.date(byAdding: .minute, value: minutes, to: now) ?? now
        let schedule = DeviceActivitySchedule(
            intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: now),
            intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: end),
            repeats: false
        )

        center.stopMonitoring([Self.graceActivityName])
        do {
            try center.startMonitoring(Self.graceActivityName, during: schedule)
            PersistenceService.shared.lastGraceMonitoringError = nil
        } catch {
            // Previously `try?` swallowed this silently. `DeviceActivityCenter.MonitoringError`
            // has a real `.intervalTooShort` case — the system enforces an undocumented minimum
            // window length, so a short grace period can fail to register at all, with the only
            // visible symptom being "the shield never comes back."
            PersistenceService.shared.lastGraceMonitoringError = "\(error)"
        }

        PersistenceService.shared.lastMirrorGateGraceGrantedAt = now
    }
}
