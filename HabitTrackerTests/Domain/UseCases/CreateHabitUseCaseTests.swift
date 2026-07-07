import Testing
@testable import Ch3Group3HabitTrackerDio

// MARK: - CreateHabitUseCase Tests

struct CreateHabitUseCaseTests {
    let repository: InMemoryHabitRepository
    let sut: CreateHabitUseCase

    init() {
        repository = InMemoryHabitRepository()
        sut = CreateHabitUseCase(repository: repository)
    }

    @Test func createsHabitWithTrimmedName() async throws {
        let habit = try await sut.execute(name: "  Run  ")
        #expect(habit.name == "Run")
    }

    @Test func habitIsPersisted() async throws {
        _ = try await sut.execute(name: "Read")
        let habits = try await repository.fetchHabits()
        #expect(habits.count == 1)
        #expect(habits.first?.name == "Read")
    }

    @Test func throwsOnEmptyName() async throws {
        await #expect(throws: HabitError.emptyName) {
            try await sut.execute(name: "")
        }
    }

    @Test func throwsOnWhitespaceName() async throws {
        await #expect(throws: HabitError.emptyName) {
            try await sut.execute(name: "   ")
        }
    }

    @Test func habitHasCorrectFrequency() async throws {
        let freq = HabitFrequency.weekly(days: [.monday, .wednesday])
        let habit = try await sut.execute(name: "Gym", frequency: freq)
        #expect(habit.frequency == freq)
    }

    @Test func createsMultipleHabits() async throws {
        _ = try await sut.execute(name: "Habit A")
        _ = try await sut.execute(name: "Habit B")
        let habits = try await repository.fetchHabits()
        #expect(habits.count == 2)
    }

    @Test("Empty name boundary — single space", arguments: [" ", "\t", "\n", "  \t  "])
    func throwsOnVariousWhitespace(name: String) async throws {
        await #expect(throws: HabitError.emptyName) {
            try await sut.execute(name: name)
        }
    }
}
