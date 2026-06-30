import Foundation

struct StoicQuote: Codable, Identifiable {
    let text: String
    let author: String
    let tags: [String]?

    var id: String { text }
}

struct QuoteCollection: Codable {
    let quotes: [StoicQuote]
}
