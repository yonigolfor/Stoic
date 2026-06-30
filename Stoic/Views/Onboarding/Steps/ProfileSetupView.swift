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
                sectionLabel(String(localized: "onboarding.profession.label"))
                professionGrid

                sectionLabel(String(localized: "onboarding.obstacle.label"))
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.stoicAccent)
            .textCase(.uppercase)
            .tracking(1.4)
    }

    private var professionGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(Profession.allCases) { profession in
                chipView(profession.rawValue, isSelected: viewModel.profession == profession) {
                    viewModel.profession = profession
                    HapticService.shared.selection()
                }
            }
        }
    }

    private var obstacleGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(CoreObstacle.allCases) { obstacle in
                chipView(obstacle.rawValue, isSelected: viewModel.coreObstacle == obstacle) {
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

// Minimal flow layout for wrapping chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map(\.maxHeight).reduce(0, +) + max(0, CGFloat(rows.count - 1)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                let size = item.sizeThatFits(.unspecified)
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
            y += row.maxHeight + spacing
        }
    }

    private struct Row {
        var items: [LayoutSubview]
        var maxHeight: CGFloat
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentItems: [LayoutSubview] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let neededWidth = currentItems.isEmpty ? size.width : currentWidth + spacing + size.width
            if neededWidth > maxWidth && !currentItems.isEmpty {
                rows.append(Row(items: currentItems, maxHeight: currentHeight))
                currentItems = [subview]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentItems.append(subview)
                currentWidth = neededWidth
                currentHeight = max(currentHeight, size.height)
            }
        }
        if !currentItems.isEmpty {
            rows.append(Row(items: currentItems, maxHeight: currentHeight))
        }
        return rows
    }
}
