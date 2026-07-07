import Foundation
import Testing
@testable import Ch3Group3HabitTrackerDio

// MARK: - GenerateStatisticsUseCase Tests

struct GenerateStatisticsUseCaseTests {
    let repository: InMemoryHabitRepository
    let sut: GenerateStatisticsUseCase
    let habit: Habit

    init() {
        habit = TestFixtures.exercise
        repository = InMemoryHabitRepository(habits: [habit])
        sut = GenerateStatisticsUseCase(repository: repository, calendar: .fixedUTC)
    }

    @Test func returnsZeroStatisticsForNewHabit() async throws {
        let stats = try await sut.execute(habit: habit)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
        #expect(stats.totalCompletions == 0)
        #expect(stats.completionRate == 0.0)
        #expect(stats.lastCompletedAt == nil)
    }

    @Test func countsCompletionsCorrectly() async throws {
        for i in 0..<3 {
            let date = Date.daysAgo(i, calendar: .fixedUTC)
            try await repository.saveCompletion(HabitCompletion(habitId: habit.id, completedAt: date))
        }
        let stats = try await sut.execute(habit: habit)
        #expect(stats.totalCompletions == 3)
        #expect(stats.currentStreak == 3)
    }

    @Test func statisticsReferenceCorrectHabit() async throws {
        let stats = try await sut.execute(habit: habit)
        #expect(stats.habit == habit)
    }

    @Test func lastCompletedAtIsTheLatestDate() async throws {
        let calendar = Calendar.fixedUTC
        let twoDaysAgo = Date.daysAgo(2, calendar: calendar)
        let yesterday = Date.daysAgo(1, calendar: calendar)
        try await repository.saveCompletion(HabitCompletion(habitId: habit.id, completedAt: twoDaysAgo))
        try await repository.saveCompletion(HabitCompletion(habitId: habit.id, completedAt: yesterday))
        let stats = try await sut.execute(habit: habit)
        let last = try #require(stats.lastCompletedAt, "Expected a lastCompletedAt date")
        #expect(calendar.isDate(last, inSameDayAs: yesterday))
    }

    @Test func completionsThisWeekCountsOnlyCurrentWeek() async throws {
        let calendar = Calendar.fixedUTC
        // 3 recent days (within a week) + 1 older day
        for i in 0..<3 {
            try await repository.saveCompletion(
                HabitCompletion(habitId: habit.id, completedAt: Date.daysAgo(i, calendar: calendar))
            )
        }
        try await repository.saveCompletion(
            HabitCompletion(habitId: habit.id, completedAt: Date.daysAgo(10, calendar: calendar))
        )
        let stats = try await sut.execute(habit: habit)
        #expect(stats.completionsThisWeek <= 3)
    }
}
