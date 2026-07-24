import SwiftUI
import SwiftData

@main
struct StoicApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @State private var showMirrorGate = false

    init() {
        LanguageService.detectOnFirstLaunch()
    }

    var body: some Scene {
        WindowGroup {
            ContentGateView()
                .onOpenURL { url in
                    // Manual test trigger — open "marcus://mirror-gate" from Safari.
                    guard url.scheme == "marcus", url.host == "mirror-gate" else { return }
                    showMirrorGate = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .stoicMirrorGateTapped)) { _ in
                    showMirrorGate = true
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    checkPendingMirrorGateTrigger()
                }
                .onAppear { checkPendingMirrorGateTrigger() }
                .fullScreenCover(isPresented: $showMirrorGate) {
                    StoicMirrorGateView(
                        onStepBack: { showMirrorGate = false },
                        onContinue: { showMirrorGate = false }
                    )
                }
        }
        .modelContainer(for: [UserProfile.self, DailyCommitment.self])
    }

    /// Cold-launch-safe path: `didReceive` in `AppDelegate` can fire before SwiftUI's
    /// `.onReceive` subscriber above even exists, so this persisted flag — checked once the
    /// scene is genuinely `.active` — is what reliably drives the Mirror Gate presentation.
    private func checkPendingMirrorGateTrigger() {
        guard PersistenceService.shared.pendingMirrorGateTrigger else { return }
        PersistenceService.shared.pendingMirrorGateTrigger = false
        showMirrorGate = true
    }
}
