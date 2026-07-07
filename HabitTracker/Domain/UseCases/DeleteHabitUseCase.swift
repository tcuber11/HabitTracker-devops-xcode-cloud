import Foundation

/// Removes a habit and all its associated completions from persistence.
struct DeleteHabitUseCase: Sendable {
    let repository: any HabitRepository

    func execute(habitId: UUID) async throws {
        try await repository.deleteHabit(id: habitId)
    }
}
