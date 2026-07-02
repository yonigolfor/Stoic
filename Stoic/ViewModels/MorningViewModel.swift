import SwiftUI
import SwiftData

@MainActor
@Observable
final class MorningViewModel {
    var quote: StoicQuote?
    var goals: [String] = ["", ""]
    var todayCommitment: DailyCommitment?
    var userProfile: UserProfile?

    var canSubmit: Bool {
        goals.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var isEveningTime: Bool {
        Calendar.current.component(.hour, from: .now) >= 17
    }

    func load(context: ModelContext) {
        userProfile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first

        let todayKey = DateFormatter.stoicDay.string(from: .now)
        let all = try? context.fetch(FetchDescriptor<DailyCommitment>())
        todayCommitment = all?.first { $0.dateKey == todayKey }

        if let existing = todayCommitment {
            quote = StoicQuote(text: existing.quoteText, author: existing.quoteAuthor, category: nil, oneWordTitleEn: nil, oneWordTitleHe: nil, textHe: nil, authorHe: nil, emoji: nil)
            goals = existing.goals
        } else {
            loadQuote()
        }
    }

    func submitCommitment(context: ModelContext) {
        guard let quote else { return }
        let commitment = DailyCommitment(
            quoteText: quote.text,
            quoteAuthor: quote.author,
            goals: goals.map { $0.trimmingCharacters(in: .whitespaces) }
        )
        context.insert(commitment)
        todayCommitment = commitment
        HapticService.shared.success()
    }

    private func loadQuote() {
        let tag = userProfile.flatMap { CoreObstacle(rawValue: $0.coreObstacle) }?.quoteTag ?? "focus"
        quote = QuoteService.randomQuote(matchingCategory: tag)
    }
}
