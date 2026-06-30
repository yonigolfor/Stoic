import UIKit

final class HapticService {
    static let shared = HapticService()
    private init() {}

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
