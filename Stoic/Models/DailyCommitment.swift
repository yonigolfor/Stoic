import Foundation
import SwiftData

@Model
final class DailyCommitment {
    var date: Date
    var quoteText: String
    var quoteAuthor: String
    var quoteTextHe: String?
    var quoteAuthorHe: String?
    var goals: [String]
    var completedFlags: [Bool]
    var reflectionNote: String
    var isEveningComplete: Bool

    init(date: Date = .now, quoteText: String, quoteAuthor: String, quoteTextHe: String? = nil, quoteAuthorHe: String? = nil, goals: [String]) {
        self.date = date
        self.quoteText = quoteText
        self.quoteAuthor = quoteAuthor
        self.quoteTextHe = quoteTextHe
        self.quoteAuthorHe = quoteAuthorHe
        self.goals = goals
        self.completedFlags = Array(repeating: false, count: goals.count)
        self.reflectionNote = ""
        self.isEveningComplete = false
    }

    var localizedQuoteText: String { LanguageService.isHebrew ? (quoteTextHe ?? quoteText) : quoteText }
    var localizedQuoteAuthor: String { LanguageService.isHebrew ? (quoteAuthorHe ?? quoteAuthor) : quoteAuthor }

    var dateKey: String {
        DateFormatter.stoicDay.string(from: date)
    }
}

extension DateFormatter {
    static let stoicDay: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
