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

    static func quoteForToday(matchingCategory category: String) -> StoicQuote? {
        let todayKey = DateFormatter.stoicDay.string(from: .now)
        let persistence = PersistenceService.shared

        if persistence.lastPickedDateKey == todayKey,
           let savedId = persistence.lastPickedQuoteId {
            let pool = resolvedPool(for: category)
            if let cached = pool.first(where: { $0.stableId == savedId }) {
                return cached
            }
        }

        let next = nextQuote(matchingCategory: category)
        persistence.lastPickedQuoteId = next?.stableId
        persistence.lastPickedDateKey = todayKey
        return next
    }

    private static func resolvedPool(for category: String) -> [StoicQuote] {
        let filtered = quotes.filter { $0.category == category }
        return filtered.isEmpty ? quotes : filtered
    }

    static func nextQuote(matchingCategory category: String) -> StoicQuote? {
        let pool = quotes.filter { $0.category == category }
        let fallback = quotes
        let activePool = pool.isEmpty ? fallback : pool
        let activeIds = Set(activePool.map(\.stableId))

        var queue = PersistenceService.shared.quoteQueue(for: category)

        // Filter dead IDs, then append any IDs not yet in the queue
        queue = queue.filter { activeIds.contains($0) }
        let queued = Set(queue)
        let newIds = activePool.map(\.stableId).filter { !queued.contains($0) }
        queue.append(contentsOf: newIds)

        // Rebuild with a fresh shuffle when exhausted
        if queue.isEmpty {
            queue = activePool.map(\.stableId).shuffled()
        }

        let nextId = queue.removeFirst()
        PersistenceService.shared.setQuoteQueue(queue, for: category)

        return activePool.first { $0.stableId == nextId } ?? activePool.first
    }
}
