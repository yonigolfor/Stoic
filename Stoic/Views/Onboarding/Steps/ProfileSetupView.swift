import SwiftUI

struct ProfileSetupView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                Text(String(localized: "onboarding.profile.title"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.stoicTextPrimary)

                Text(String(localized: "onboarding.profile.subtitle"))
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
                    .lineSpacing(3)
            }
            .padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 20) {
                SectionLabel(title: String(localized: "onboarding.profession.label"))
                professionGrid

                SectionLabel(title: String(localized: "onboarding.obstacle.label"))
                    .padding(.top, 4)
                obstacleGrid
            }

            Spacer()
            Spacer()

            StoicButton(title: String(localized: "action.continue")) {
                viewModel.advance()
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    private var professionGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(Profession.allCases) { profession in
                chipView(profession.localizedLabel, isSelected: viewModel.profession == profession) {
                    viewModel.profession = profession
                    HapticService.shared.selection()
                }
            }
        }
    }

    private var obstacleGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(CoreObstacle.allCases) { obstacle in
                chipView(obstacle.localizedLabel, isSelected: viewModel.coreObstacle == obstacle) {
                    viewModel.coreObstacle = obstacle
                    HapticService.shared.selection()
                }
            }
        }
    }

    private func chipView(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
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

