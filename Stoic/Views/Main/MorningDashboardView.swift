import SwiftUI
import SwiftData

struct MorningDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: MorningViewModel
    @State private var showEvening = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                dateHeader
                if let quote = viewModel.quote { quoteCard(quote) }

                if viewModel.todayCommitment == nil {
                    goalsSection
                    StoicButton(title: String(localized: "morning.commit")) {
                        viewModel.submitCommitment(context: modelContext)
                    }
                    .disabled(!viewModel.canSubmit)
                    .opacity(viewModel.canSubmit ? 1 : 0.4)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.canSubmit)
                } else {
                    committedGoalsView
                    if viewModel.isEveningTime {
                        StoicButton(title: String(localized: "morning.evening_review"), style: .secondary) {
                            showEvening = true
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(Color.stoicBackground.ignoresSafeArea())
        .sheet(isPresented: $showEvening) {
            if let commitment = viewModel.todayCommitment {
                EveningReflectionView(commitment: commitment)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, style: .date)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.stoicAccent)
                .textCase(.uppercase)
                .tracking(1.4)

            Text(String(localized: "morning.title"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.stoicTextPrimary)
        }
    }

    private func quoteCard(_ quote: StoicQuote) -> some View {
        PremiumCardView {
            VStack(alignment: .leading, spacing: 14) {
                if let profile = viewModel.userProfile {
                    Text(contextLine(profile: profile))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.stoicAccent)
                        .tracking(0.6)
                        .textCase(.uppercase)
                }

                Text(quote.text)
                    .font(.system(size: 22, weight: .medium, design: .serif))
                    .foregroundStyle(Color.stoicTextPrimary)
                    .lineSpacing(6)

                Text("— \(quote.author)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
            }
        }
    }

    private func contextLine(profile: UserProfile) -> String {
        "\(profile.name) · \(profile.profession) · \(profile.coreObstacle)"
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: String(localized: "morning.goals.title"))

            ForEach(0..<2, id: \.self) { i in
                goalField(index: i)
            }
        }
    }

    private func goalField(index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.stoicAccent)
                .frame(width: 20)
                .padding(.top, 15)

            TextField(String(localized: "morning.goal.placeholder"), text: $viewModel.goals[index], axis: .vertical)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.stoicTextPrimary)
                .tint(Color.stoicAccent)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.stoicSurface)
                )
                .lineLimit(2...4)
        }
    }

    private var committedGoalsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: String(localized: "morning.goals.committed"))

            ForEach(Array((viewModel.todayCommitment?.goals ?? []).enumerated()), id: \.offset) { _, goal in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.stoicAccent)
                        .font(.system(size: 18))
                        .padding(.top, 1)

                    Text(goal)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.stoicTextPrimary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.stoicSurface)
                )
            }
        }
    }

}
