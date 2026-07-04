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
