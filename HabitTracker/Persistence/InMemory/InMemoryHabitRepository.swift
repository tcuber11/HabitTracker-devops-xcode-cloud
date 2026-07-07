import Foundation

/// Thread-safe in-memory implementation of `HabitRepository`.
/// Used exclusively in tests and SwiftUI Previews.
/// The class is isolated to the MainActor (via project-wide default isolation),
/// so it is always accessed from the main thread.
final class InMemoryHabitRepository: HabitRepository {
    private(set) var habits: [Habit] = []
    private(set) var completions: [HabitCompletion] = []

    init(habits: [Habit] = [], completions: [HabitCompletion] = []) {
        self.habits = habits
        self.completions = completions
    }

    // MARK: - Habits

    func fetchHabits() async throws -> [Habit] {
        habits
    }

    func saveHabit(_ habit: Habit) async throws {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
        } else {
            habits.append(habit)
        }
    }

    func deleteHabit(id: UUID) async throws {
        guard habits.contains(where: { $0.id == id }) else {
            throw HabitError.habitNotFound(id)
        }
        habits.removeAll { $0.id == id }
        completions.removeAll { $0.habitId == id }
    }

    // MARK: - Completions

    func fetchCompletions(for habitId: UUID) async throws -> [HabitCompletion] {
        completions.filter { $0.habitId == habitId }
    }

    func fetchAllCompletions() async throws -> [HabitCompletion] {
        completions
    }

    func saveCompletion(_ completion: HabitCompletion) async throws {
        completions.append(completion)
    }

    func deleteCompletion(id: UUID) async throws {
        guard completions.contains(where: { $0.id == id }) else {
            throw HabitError.completionNotFound(id)
        }
        completions.removeAll { $0.id == id }
    }
}
