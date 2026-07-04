import SwiftUI
import SwiftData

struct MainSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MorningViewModel()
    var onReset: () -> Void

    var body: some View {
        ZStack {
            Color.stoicBackground.ignoresSafeArea()

            if let commitment = viewModel.todayCommitment, commitment.isEveningComplete {
                EveningReflectionView(commitment: commitment)
            } else {
                MorningDashboardView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.load(context: modelContext)
        }
        #if DEBUG
        .overlay(alignment: .topLeading) {
            Button(action: resetApp) {
                Image(systemName: "arrow.counterclockwise.circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.stoicTextSecondary.opacity(0.5))
                    .padding(.top, 58)
                    .padding(.leading, 20)
            }
        }
        #endif
    }

    #if DEBUG
    private func resetApp() {
        try? modelContext.delete(model: UserProfile.self)
        try? modelContext.delete(model: DailyCommitment.self)
        PersistenceService.shared.hasCompletedOnboarding = false
        PersistenceService.shared.clearAllQuoteQueues()
        LanguageService.redetect()
        HapticService.shared.success()
        onReset()
    }
    #endif
}
