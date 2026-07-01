import Foundation
import SwiftData

@Model
final class DailyCommitment {
    var date: Date
    var quoteText: String
    var quoteAuthor: String
    var goals: [String]
    var completedFlags: [Bool]
    var reflectionNote: String
    var isEveningComplete: Bool

    init(date: Date = .now, quoteText: String, quoteAuthor: String, goals: [String]) {
        self.date = date
        self.quoteText = quoteText
        self.quoteAuthor = quoteAuthor
        self.goals = goals
        self.completedFlags = Array(repeating: false, count: goals.count)
        self.reflectionNote = ""
        self.isEveningComplete = false
    }

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
