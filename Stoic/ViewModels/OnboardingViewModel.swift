import SwiftUI
import SwiftData

@MainActor
@Observable
final class OnboardingViewModel {
    var name: String = ""
    var profession: Profession = .entrepreneur
    var coreObstacle: CoreObstacle = .focus
    var morningTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? .now
    var eveningTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    var currentStep: Int = 0

    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func advance() {
        HapticService.shared.light()
        withAnimation(.easeInOut(duration: 0.35)) {
            currentStep += 1
        }
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
}
