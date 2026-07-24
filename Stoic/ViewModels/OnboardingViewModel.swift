import SwiftUI
import SwiftData
import FamilyControls
import ManagedSettings

@MainActor
@Observable
final class OnboardingViewModel {
    private let store = ManagedSettingsStore()
    var name: String = ""
    var profession: Profession = .entrepreneur
    var coreObstacle: CoreObstacle = .focus
    var morningTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? .now
    var eveningTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    var currentStep: Int = 0

    // Friction Gate app selection
    var selectedFocusApps: Set<FocusAppOption> = []
    var activitySelection = FamilyActivitySelection()
    var showActivityPicker: Bool = false

    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func advance() {
        HapticService.shared.light()
        // The TabView's own `.animation(value: currentStep)` modifier drives the transition;
        // wrapping this in a second `withAnimation` here layered a redundant transaction on
        // top of it, which is what caused the snap-back glitch after the picker sheet closed.
        currentStep += 1
    }

    func saveProfile(context: ModelContext) async {
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            profession: profession.rawValue,
            coreObstacle: coreObstacle.rawValue
        )
        context.insert(profile)

        let morningString = timeString(from: morningTime)
        let eveningString = timeString(from: eveningTime)
        PersistenceService.shared.morningNotificationTime = morningString
        PersistenceService.shared.eveningNotificationTime = eveningString

        let granted = await NotificationManager.shared.requestAuthorization()
        if granted {
            NotificationManager.shared.scheduleMorningNotification(timeString: morningString)
            NotificationManager.shared.scheduleEveningNotification(timeString: eveningString)
        }

        PersistenceService.shared.hasCompletedOnboarding = true
        HapticService.shared.success()
    }

    private func timeString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    // MARK: - Friction Gate

    func toggleFocusApp(_ app: FocusAppOption) {
        if selectedFocusApps.contains(app) {
            selectedFocusApps.remove(app)
        } else {
            selectedFocusApps.insert(app)
        }
        HapticService.shared.selection()
    }

    func presentFamilyActivityPicker() {
        showActivityPicker = true
    }

    var isScreenTimeAuthorized: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    /// Requests Screen Time authorization. Never throws to the caller: without the
    /// entitlement/on unsupported devices this fails silently and the caller falls back
    /// to advancing onboarding without ever shielding anything.
    @discardableResult
    func requestScreenTimeAuthorization() async -> Bool {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            // Denied, unsupported, or pre-entitlement. Caller checks `isScreenTimeAuthorized`.
        }
        return isScreenTimeAuthorized
    }

    /// Applies the real system Shield to whatever apps were chosen in the native
    /// FamilyActivityPicker, then persists the selection and advances onboarding.
    func applyShieldAndAdvance() {
        store.shield.applications = activitySelection.applicationTokens.isEmpty
            ? nil
            : activitySelection.applicationTokens

        if let encoded = try? JSONEncoder().encode(activitySelection) {
            PersistenceService.shared.selectedFocusAppsRaw = encoded
        }

        // Deferred one runloop tick: this fires from `.onChange(of: showActivityPicker)`
        // while the native picker sheet is still mid-dismissal — advancing the TabView's
        // selection synchronously in that same transaction is what caused the snap-back.
        DispatchQueue.main.async { [self] in
            advance()
        }
    }
}
