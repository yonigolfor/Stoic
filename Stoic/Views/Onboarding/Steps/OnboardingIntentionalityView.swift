import SwiftUI
import FamilyControls

struct OnboardingIntentionalityView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "onboarding.intentionality.title", bundle: LanguageService.currentBundle))
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoicTextPrimary)

                Text(String(localized: "onboarding.intentionality.subtitle", bundle: LanguageService.currentBundle))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
                    .lineSpacing(3)
            }
            .padding(.bottom, 32)

            appGrid

            Spacer()
            Spacer()

            VStack(spacing: 12) {
                StoicButton(title: String(localized: "onboarding.intentionality.cta", bundle: LanguageService.currentBundle)) {
                    Task {
                        let authorized = await viewModel.requestScreenTimeAuthorization()
                        if authorized {
                            HapticService.shared.success()
                            viewModel.presentFamilyActivityPicker()
                        } else {
                            // No entitlement / denied / unsupported device — advance without shielding anything.
                            viewModel.advance()
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .familyActivityPicker(isPresented: $viewModel.showActivityPicker, selection: $viewModel.activitySelection)
        .onChange(of: viewModel.showActivityPicker) { _, isPresented in
            guard !isPresented else { return }
            viewModel.applyShieldAndAdvance()
        }
    }

    private var appGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(FocusAppOption.allCases) { app in
                chipView(app, isSelected: viewModel.selectedFocusApps.contains(app)) {
                    viewModel.toggleFocusApp(app)
                }
            }
        }
    }

    private func chipView(_ app: FocusAppOption, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(app.rawValue, systemImage: app.systemImage)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.stoicBackground : Color.stoicTextSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? Color.stoicAccent : Color.stoicSurface)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
