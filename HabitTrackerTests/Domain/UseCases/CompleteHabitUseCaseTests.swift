import Foundation
import Testing
@testable import AcademyHabitTracker

// MARK: - CompleteHabitUseCase Tests

struct CompleteHabitUseCaseTests {
    let repository: InMemoryHabitRepository
    let sut: CompleteHabitUseCase
    let habit: Habit

    init() {
        habit = TestFixtures.exercise
        repository = InMemoryHabitRepository(habits: [habit])
        sut = CompleteHabitUseCase(repository: repository)
    }

    @Test func completesHabitSuccessfully() async throws {
        let completion = try await sut.execute(habit: habit)
        #expect(completion.habitId == habit.id)
    }

    @Test func completionIsPersistedToRepository() async throws {
        _ = try await sut.execute(habit: habit)
        let completions = try await repository.fetchCompletions(for: habit.id)
        #expect(completions.count == 1)
    }

    @Test func throwsWhenAlreadyCompletedToday() async throws {
        _ = try await sut.execute(habit: habit, date: Date())
        await #expect(throws: HabitError.alreadyCompletedToday) {
            try await sut.execute(habit: habit, date: Date())
        }
    }

    @Test func allowsCompletionOnDifferentDays() async throws {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        _ = try await sut.execute(habit: habit, date: yesterday)
        let completion = try await sut.execute(habit: habit, date: today)
        #expect(completion.habitId == habit.id)
        let completions = try await repository.fetchCompletions(for: habit.id)
        #expect(completions.count == 2)
    }

    @Test func completionNoteIsPreserved() async throws {
        let completion = try await sut.execute(habit: habit, note: "Felt great!")
        #expect(completion.note == "Felt great!")
    }

    @Test func completionDateIsPreserved() async throws {
        let specificDate = Date(timeIntervalSince1970: 1_000_000)
        let completion = try await sut.execute(habit: habit, date: specificDate)
        #expect(Calendar.current.isDate(completion.completedAt, inSameDayAs: specificDate))
    }
}
