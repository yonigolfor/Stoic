import Foundation

enum QuoteService {
    private static let quotes: [StoicQuote] = {
        guard
            let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let collection = try? JSONDecoder().decode(QuoteCollection.self, from: data)
        else { return [] }
        return collection.quotes
    }()

    static func randomQuote(matchingCategory category: String) -> StoicQuote? {
        let filtered = quotes.filter { $0.category == category }
        return filtered.isEmpty ? quotes.randomElement() : filtered.randomElement()
    }
}
