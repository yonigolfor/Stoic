import SwiftUI
import SwiftData

struct EveningReflectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = EveningViewModel()
    let commitment: DailyCommitment

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                quoteRecap
                goalsCompletion
                reflectionInput

                if viewModel.isSaved {
                    savedBadge
                } else {
                    StoicButton(title: String(localized: "evening.save", bundle: LanguageService.currentBundle)) {
                        viewModel.saveReflection(context: modelContext)
                    }
                }
            }
            .padding(24)
        }
        .background(Color.stoicBackground.ignoresSafeArea())
        .onAppear { viewModel.load(commitment: commitment) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(localized: "evening.subtitle", bundle: LanguageService.currentBundle))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.stoicAccent)
                .textCase(.uppercase)
                .tracking(1.4)

            Text(String(localized: "evening.title", bundle: LanguageService.currentBundle))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.stoicTextPrimary)
        }
    }

    private var quoteRecap: some View {
        PremiumCardView {
            VStack(alignment: .leading, spacing: 10) {
                Text(commitment.localizedQuoteText)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(Color.stoicTextPrimary)
                    .lineSpacing(5)

                Text("— \(commitment.localizedQuoteAuthor)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.stoicTextSecondary)
            }
        }
    }

    private var goalsCompletion: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: String(localized: "evening.goals.title", bundle: LanguageService.currentBundle))

            ForEach(Array(commitment.goals.enumerated()), id: \.offset) { i, goal in
                goalRow(goal: goal, index: i)
            }
        }
    }

    private func goalRow(goal: String, index: Int) -> some View {
        let isCompleted = viewModel.commitment?.completedFlags[safe: index] ?? false

        return Button {
            guard !viewModel.isSaved else { return }
            viewModel.toggleGoal(at: index)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(isCompleted ? Color.stoicAccent : Color.stoicTextSecondary)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)

                Text(goal)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isCompleted ? Color.stoicTextPrimary : Color.stoicTextSecondary)
                    .strikethrough(isCompleted, color: Color.stoicTextSecondary)
                    .animation(.easeInOut(duration: 0.2), value: isCompleted)

                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.stoicSurface)
            )
        }
        .buttonStyle(.plain)
    }

    private var reflectionInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel(title: String(localized: "evening.reflection.title", bundle: LanguageService.currentBundle))

            TextField(
                String(localized: "evening.reflection.placeholder", bundle: LanguageService.currentBundle),
                text: $viewModel.reflectionNote,
                axis: .vertical
            )
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(Color.stoicTextPrimary)
            .tint(Color.stoicAccent)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.stoicSurface)
            )
            .lineLimit(4...8)
            .disabled(viewModel.isSaved)
        }
    }

    private var savedBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.stoicAccent)

            Text(String(localized: "evening.saved", bundle: LanguageService.currentBundle))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.stoicTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.stoicSurface)
        )
    }
}

