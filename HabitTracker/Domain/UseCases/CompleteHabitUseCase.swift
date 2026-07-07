import Foundation

/// Records a completion for a habit on a given date.
///
/// Business rules:
/// - A habit can only be completed once per calendar day.
/// - Attempting to complete it again on the same day throws `HabitError.alreadyCompletedToday`.
struct CompleteHabitUseCase: Sendable {
    let repository: any HabitRepository

    /// - Parameters:
    ///   - habit: The habit to complete.
    ///   - note: Optional note attached to this completion.
    ///   - date: The date the habit is being completed. Defaults to the current date.
    /// - Returns: The persisted `HabitCompletion`.
    /// - Throws: `HabitError.alreadyCompletedToday` if already completed on `date`.
    func execute(
        habit: Habit,
        note: String = "",
        date: Date = Date()
    ) async throws -> HabitCompletion {
        let completions = try await repository.fetchCompletions(for: habit.id)
        let calendar = Calendar.current
        let alreadyDone = completions.contains {
            calendar.isDate($0.completedAt, inSameDayAs: date)
        }
        guard !alreadyDone else {
            throw HabitError.alreadyCompletedToday
        }
        let completion = HabitCompletion(habitId: habit.id, completedAt: date, note: note)
        try await repository.saveCompletion(completion)
        return completion
    }
}
