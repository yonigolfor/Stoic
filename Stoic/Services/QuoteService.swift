import Foundation

enum QuoteService {
    static func randomQuote(matchingTag tag: String) -> StoicQuote? {
        guard
            let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let collection = try? JSONDecoder().decode(QuoteCollection.self, from: data)
        else { return nil }

        let filtered = collection.quotes.filter { $0.tags?.contains(tag) == true }
        return filtered.isEmpty ? collection.quotes.randomElement() : filtered.randomElement()
    }
}
