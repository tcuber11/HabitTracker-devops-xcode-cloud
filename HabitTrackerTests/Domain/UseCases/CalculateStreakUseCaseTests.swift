import Foundation
import Testing
@testable import AcademyHabitTracker

// MARK: - CalculateStreakUseCase Tests
//
// These tests use a fixed UTC calendar to avoid timezone and DST sensitivity.

struct CalculateStreakUseCaseTests {
    let calendar: Calendar
    let sut: CalculateStreakUseCase
    let habit: Habit

    init() {
        calendar = .fixedUTC
        sut = CalculateStreakUseCase(calendar: .fixedUTC)
        habit = TestFixtures.exercise
    }

    // MARK: - Daily Habit Streak

    @Test func noCompletionsProducesZeroStreak() {
        let result = sut.execute(habit: habit, completions: [], from: .now)
        #expect(result.current == 0)
        #expect(result.longest == 0)
    }

    @Test func singleTodayCompletionProducesStreakOfOne() {
        let today = calendar.startOfDay(for: Date())
        let completions = [HabitCompletion(habitId: habit.id, completedAt: today)]
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == 1)
        #expect(result.longest == 1)
    }

    @Test func consecutiveDaysProduceCorrectCurrentStreak() {
        let today = calendar.startOfDay(for: Date())
        let completions = (0..<5).map { daysAgo -> HabitCompletion in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return HabitCompletion(habitId: habit.id, completedAt: date)
        }
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == 5)
        #expect(result.longest == 5)
    }

    @Test func brokenStreakResetsCurrentButPreservesLongest() {
        let today = calendar.startOfDay(for: Date())
        // Days 0, 1, 2 ago (streak of 3) then a gap, then days 5, 6, 7, 8, 9 ago (streak of 5)
        let recentDays = [0, 1, 2]
        let olderDays = [5, 6, 7, 8, 9]
        let completions = (recentDays + olderDays).map { daysAgo -> HabitCompletion in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return HabitCompletion(habitId: habit.id, completedAt: date)
        }
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == 3)
        #expect(result.longest == 5)
    }

    @Test func missedTodayProducesZeroCurrentStreak() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let completions = [HabitCompletion(habitId: habit.id, completedAt: yesterday)]
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == 0)
        #expect(result.longest == 1)
    }

    @Test func duplicateCompletionsOnSameDayCountAsOne() {
        let today = calendar.startOfDay(for: Date())
        let completions = [
            HabitCompletion(habitId: habit.id, completedAt: today),
            HabitCompletion(habitId: habit.id, completedAt: today.addingTimeInterval(3600))
        ]
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == 1)
    }

    // MARK: - Parameterized Streak Length Tests

    @Test("Consecutive completions produce matching streak", arguments: [1, 3, 7, 14, 30])
    func streakLengthMatchesConsecutiveCompletions(count: Int) {
        let today = calendar.startOfDay(for: Date())
        let completions = (0..<count).map { daysAgo -> HabitCompletion in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return HabitCompletion(habitId: habit.id, completedAt: date)
        }
        let result = sut.execute(habit: habit, completions: completions, from: today)
        #expect(result.current == count, "Expected streak of \(count)")
        #expect(result.longest >= count)
    }
}
