import Foundation

/// Abstract persistence contract for the habit domain.
/// All three architectures depend on this protocol — never on a concrete implementation.
///
/// Dependency direction: Domain ← Infrastructure (SwiftData / InMemory)
protocol HabitRepository: Sendable {
    // MARK: - Habits
    func fetchHabits() async throws -> [Habit]
    func saveHabit(_ habit: Habit) async throws
    func deleteHabit(id: UUID) async throws

    // MARK: - Completions
    func fetchCompletions(for habitId: UUID) async throws -> [HabitCompletion]
    func fetchAllCompletions() async throws -> [HabitCompletion]
    func saveCompletion(_ completion: HabitCompletion) async throws
    func deleteCompletion(id: UUID) async throws
}
