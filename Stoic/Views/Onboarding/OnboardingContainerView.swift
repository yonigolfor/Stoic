import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void

    private let totalSteps = 4

    var body: some View {
        ZStack {
            Color.stoicBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                TabView(selection: $viewModel.currentStep) {
                    NameSetupView(viewModel: viewModel).tag(0)
                    ProfileSetupView(viewModel: viewModel).tag(1)
                    OnboardingIntentionalityView(viewModel: viewModel).tag(2)
                    TimeSetupView(viewModel: viewModel) {
                        Task { await complete() }
                    }.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i <= viewModel.currentStep ? Color.stoicAccent : Color.stoicSurface)
                    .frame(height: 3)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
    }

    private func complete() async {
        await viewModel.saveProfile(context: modelContext)
        onComplete()
    }
}
