import SwiftUI
import SwiftData

@main
struct StoicApp: App {
    init() {
        LanguageService.detectOnFirstLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentGateView()
        }
        .modelContainer(for: [UserProfile.self, DailyCommitment.self])
    }
}
