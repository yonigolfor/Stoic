import SwiftUI

@MainActor
@Observable
final class MirrorGateViewModel {
    let camera = CameraPreviewService()
    private let gateService: ScreenTimeGateServicing

    init(gateService: ScreenTimeGateServicing? = nil) {
        self.gateService = gateService ?? ScreenTimeGateService()
    }

    func onAppear() {
        camera.start()
    }

    func onDisappear() {
        camera.stop()
    }

    func stepBack(onComplete: () -> Void) {
        PersistenceService.shared.recordFocusVictory()
        HapticService.shared.success()
        onComplete()
    }

    func continueAnyway(onComplete: () -> Void) {
        gateService.grantGracePeriod(minutes: 15)
        HapticService.shared.light()
        onComplete()
    }
}
