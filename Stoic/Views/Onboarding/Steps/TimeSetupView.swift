import SwiftUI

struct TimeSetupView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "onboarding.time.title"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stoicTextPrimary)

                Text(String(localized: "onboarding.time.subtitle"))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
                    .lineSpacing(3)
            }
            .padding(.bottom, 36)

            VStack(spacing: 12) {
                timeCard(
                    icon: "sunrise.fill",
                    label: String(localized: "onboarding.morning.label"),
                    selection: $viewModel.morningTime
                )

                timeCard(
                    icon: "moon.fill",
                    label: String(localized: "onboarding.evening.label"),
                    selection: $viewModel.eveningTime
                )
            }

            Spacer()
            Spacer()

            StoicButton(title: String(localized: "onboarding.begin")) {
                onComplete()
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    private func timeCard(icon: String, label: String, selection: Binding<Date>) -> some View {
        PremiumCardView {
            HStack {
                Label(label, systemImage: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.stoicAccent)

                Spacer()

                DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .tint(Color.stoicAccent)
            }
        }
    }
}
