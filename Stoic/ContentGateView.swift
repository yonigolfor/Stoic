import SwiftUI

struct ContentGateView: View {
    @State private var hasOnboarded = PersistenceService.shared.hasCompletedOnboarding

    var body: some View {
        Group {
            if hasOnboarded {
                MainSessionView()
            } else {
                OnboardingContainerView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        hasOnboarded = true
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
