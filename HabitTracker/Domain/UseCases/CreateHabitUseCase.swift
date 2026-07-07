import Foundation

/// Creates and persists a new Habit after validating the input.
///
/// Business rules:
/// - Name must not be blank after trimming whitespace.
/// - Habit is saved via the repository before being returned.
struct CreateHabitUseCase: Sendable {
    let repository: any HabitRepository

    /// - Parameters:
    ///   - name: Human-readable name. Whitespace is trimmed; empty strings are rejected.
    ///   - description: Optional description.
    ///   - frequency: How often the habit must be performed.
    /// - Returns: The newly created and persisted `Habit`.
    /// - Throws: `HabitError.emptyName` if the trimmed name is empty.
    func execute(
        name: String,
        description: String = "",
        frequency: HabitFrequency = .daily
    ) async throws -> Habit {
        let trimmed = name.trimmingCharacters(in: .newlines)
        guard !trimmed.isEmpty else {
            throw HabitError.emptyName
        }
        let habit = Habit(name: trimmed, habitDescription: description, frequency: frequency)
        try await repository.saveHabit(habit)
        return habit
    }
}
