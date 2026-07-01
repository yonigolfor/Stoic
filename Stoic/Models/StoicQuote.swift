import Foundation

struct StoicQuote: Codable, Identifiable {
    let text: String
    let author: String
    let category: String?
    let oneWordTitle: String?
    let emoji: String?

    var id: String { text }

    enum CodingKeys: String, CodingKey {
        case text, author, category, emoji
        case oneWordTitle = "one_word_title"
    }
}

struct QuoteCollection: Codable {
    let quotes: [StoicQuote]
}
