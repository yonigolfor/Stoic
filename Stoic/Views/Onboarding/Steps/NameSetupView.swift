import SwiftUI

struct NameSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "onboarding.name.title", bundle: LanguageService.currentBundle))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stoicTextPrimary)

                Text(String(localized: "onboarding.name.subtitle", bundle: LanguageService.currentBundle))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
                    .lineSpacing(3)
            }
            .padding(.bottom, 36)

            TextField(String(localized: "onboarding.name.placeholder", bundle: LanguageService.currentBundle), text: $viewModel.name)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color.stoicTextPrimary)
                .tint(Color.stoicAccent)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.stoicSurface)
                )
                .focused($isFocused)
                .submitLabel(.next)
                .onSubmit {
                    if viewModel.isNameValid { viewModel.advance() }
                }

            Spacer()
            Spacer()

            StoicButton(title: String(localized: "action.continue", bundle: LanguageService.currentBundle)) {
                viewModel.advance()
            }
            .disabled(!viewModel.isNameValid)
            .opacity(viewModel.isNameValid ? 1 : 0.4)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isNameValid)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .onAppear { isFocused = true }
        .onChange(of: viewModel.currentStep) { _, newStep in
            // TabView(.page) keeps neighboring pages mounted, so this field never
            // naturally resigns focus when the user swipes/advances away from it.
            isFocused = (newStep == 0)
        }
    }
}
