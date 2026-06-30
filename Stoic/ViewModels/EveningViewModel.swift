import SwiftUI
import SwiftData

@MainActor
@Observable
final class EveningViewModel {
    private(set) var commitment: DailyCommitment?
    var reflectionNote: String = ""
    var isSaved: Bool = false

    func load(commitment: DailyCommitment) {
        self.commitment = commitment
        reflectionNote = commitment.reflectionNote
        isSaved = commitment.isEveningComplete
    }

    func toggleGoal(at index: Int) {
        guard let commitment, commitment.completedFlags.indices.contains(index) else { return }
        commitment.completedFlags[index].toggle()
        HapticService.shared.selection()
    }

    func saveReflection(context: ModelContext) {
        guard let commitment else { return }
        commitment.reflectionNote = reflectionNote.trimmingCharacters(in: .whitespaces)
        commitment.isEveningComplete = true
        isSaved = true
        updateStreak(context: context)
        HapticService.shared.success()
    }

    private func updateStreak(context: ModelContext) {
        let descriptor = FetchDescriptor<DailyCommitment>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        guard let all = try? context.fetch(descriptor) else { return }

        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: .now)

        for entry in all where entry.isEveningComplete {
            let entryDay = Calendar.current.startOfDay(for: entry.date)
            if entryDay == checkDate {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }

        PersistenceService.shared.currentStreak = streak
    }
}
