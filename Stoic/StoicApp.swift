import SwiftUI
import SwiftData

@main
struct StoicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentGateView()
        }
        .modelContainer(for: [UserProfile.self, DailyCommitment.self])
    }
}
