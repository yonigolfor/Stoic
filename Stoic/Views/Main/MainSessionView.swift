import SwiftUI
import SwiftData

struct MainSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MorningViewModel()

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
    }
}
