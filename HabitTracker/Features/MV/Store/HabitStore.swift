import Foundation
import Observation

/// # MV Architecture — HabitStore
///
/// The Store is the single source of truth for the MV architecture.
/// It owns all application state and coordinates use cases.
///
/// ## Responsibilities:
/// - Own and mutate application state
/// - Delegate all business rules to Use Cases
/// - Publish state changes via `@Observable` for automatic view updates
///
/// ## What the Store does NOT do:
/// - Contain business logic (that lives in Use Cases)
/// - Perform direct I/O (the repository abstracts that)
/// - Know about view presentation (that belongs in views)
///
/// Views consume the store via `@Environment(HabitStore.self)`.
/// There is no intermediate ViewModel — SwiftUI's Observation handles reactivity directly.
@Observable
final class HabitStore {

    // MARK: - State
    // All state is read-only from outside; only the store mutates it.

    private(set) var habits: [Habit] = []
    private(set) var statistics: [UUID: HabitStatistics] = [:]
    private(set) var isLoading = false
    private(set) var error: HabitError?

    // MARK: - Dependencies (Use Cases)
    // Use Cases are the boundary between the store and business logic.
    // Each use case owns a single responsibility.

    private let repository: any HabitRepository
    private let createHabitUseCase: CreateHabitUseCase
    private let completeHabitUseCase: CompleteHabitUseCase
    private let deleteHabitUseCase: DeleteHabitUseCase
    private let generateStatisticsUseCase: GenerateStatisticsUseCase

    // MARK: - Init

    init(repository: any HabitRepository) {
        self.repository = repository
        self.createHabitUseCase = CreateHabitUseCase(repository: repository)
        self.completeHabitUseCase = CompleteHabitUseCase(repository: repository)
        self.deleteHabitUseCase = DeleteHabitUseCase(repository: repository)
        self.generateStatisticsUseCase = GenerateStatisticsUseCase(repository: repository)
    }

    // MARK: - Actions

    func loadHabits() async {
        isLoading = true
        defer { isLoading = false }
        do {
            habits = try await repository.fetchHabits()
            await refreshStatistics()
        } catch {
            self.error = error as? HabitError ?? .persistence(error.localizedDescription)
        }
    }

    func createHabit(name: String, description: String, frequency: HabitFrequency) async {
        do {
            let habit = try await createHabitUseCase.execute(
                name: name,
                description: description,
                frequency: frequency
            )
            habits.append(habit)
        } catch {
            self.error = error as? HabitError ?? .persistence(error.localizedDescription)
        }
    }

    func completeHabit(_ habit: Habit) async {
        do {
            _ = try await completeHabitUseCase.execute(habit: habit)
            if let stats = try? await generateStatisticsUseCase.execute(habit: habit) {
                statistics[habit.id] = stats
            }
        } catch {
            self.error = error as? HabitError ?? .persistence(error.localizedDescription)
        }
    }

    func deleteHabits(at offsets: IndexSet) async {
        let targets = offsets.map { habits[$0] }
        for habit in targets {
            do {
                try await deleteHabitUseCase.execute(habitId: habit.id)
                habits.removeAll { $0.id == habit.id }
                statistics.removeValue(forKey: habit.id)
            } catch {
                self.error = error as? HabitError ?? .persistence(error.localizedDescription)
            }
        }
    }

    func clearError() {
        error = nil
    }

    // MARK: - Private

    private func refreshStatistics() async {
        await withDiscardingTaskGroup { group in
            for habit in habits {
                group.addTask { [weak self] in
                    guard let self else { return }
                    if let stats = try? await generateStatisticsUseCase.execute(habit: habit) {
                        statistics[habit.id] = stats
                    }
                }
            }
        }
    }
}
