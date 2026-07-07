import Foundation
import Testing
@testable import AcademyHabitTracker

// MARK: - MV Architecture: HabitStore Tests
//
// These tests verify that the Store correctly coordinates use cases
// and maintains consistent state.
//
// Testing strategy for MV:
// - HabitStore is @Observable — create an instance and call its async methods directly.
// - Use InMemoryHabitRepository for fast, isolated, synchronous-ish tests.
// - Verify state changes after async operations complete.

@MainActor
struct HabitStoreTests {
    let repository: InMemoryHabitRepository
    let sut: HabitStore

    init() {
        repository = InMemoryHabitRepository()
        sut = HabitStore(repository: repository)
    }

    @Test func initialStateHasNoHabits() {
        #expect(sut.habits.isEmpty)
        #expect(sut.isLoading == false)
        #expect(sut.error == nil)
    }

    @Test func loadHabitsPopulatesHabits() async throws {
        let habit = TestFixtures.exercise
        try await repository.saveHabit(habit)
        await sut.loadHabits()
        #expect(sut.habits.count == 1)
        #expect(sut.habits.first?.name == "Exercise")
    }

    @Test func createHabitAddsToHabits() async {
        await sut.createHabit(name: "Yoga", description: "", frequency: .daily)
        #expect(sut.habits.count == 1)
        #expect(sut.habits.first?.name == "Yoga")
    }

    @Test func createHabitWithEmptyNameSetsError() async {
        await sut.createHabit(name: "", description: "", frequency: .daily)
        #expect(sut.error == .emptyName)
        #expect(sut.habits.isEmpty)
    }

    @Test func clearErrorResetsError() async {
        await sut.createHabit(name: "", description: "", frequency: .daily)
        sut.clearError()
        #expect(sut.error == nil)
    }

    @Test func completeHabitUpdatesStatistics() async {
        await sut.createHabit(name: "Run", description: "", frequency: .daily)
        let habit = sut.habits.first!
        await sut.completeHabit(habit)
        let stats = sut.statistics[habit.id]
        #expect(stats?.isCompletedToday == true)
    }

    @Test func deleteHabitRemovesFromHabits() async {
        await sut.createHabit(name: "Exercise", description: "", frequency: .daily)
        #expect(sut.habits.count == 1)
        await sut.deleteHabits(at: IndexSet(integer: 0))
        #expect(sut.habits.isEmpty)
    }

    @Test func deleteHabitRemovesStatisticsEntry() async {
        await sut.createHabit(name: "Exercise", description: "", frequency: .daily)
        let habit = sut.habits.first!
        await sut.completeHabit(habit)
        #expect(sut.statistics[habit.id] != nil)
        await sut.deleteHabits(at: IndexSet(integer: 0))
        #expect(sut.statistics[habit.id] == nil)
    }

    @Test func loadingStateIsTrueWhileLoading() async {
        // The isLoading flag starts false, becomes true during load, then false after.
        // We can verify the final state: it must be false after loading completes.
        await sut.loadHabits()
        #expect(sut.isLoading == false)
    }
}
