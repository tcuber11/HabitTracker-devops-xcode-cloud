import Foundation
import Testing
@testable import AcademyHabitTracker

// MARK: - CalculateCompletionRateUseCase Tests

struct CalculateCompletionRateUseCaseTests {
    let calendar: Calendar
    let sut: CalculateCompletionRateUseCase
    let habit: Habit

    init() {
        calendar = .fixedUTC
        sut = CalculateCompletionRateUseCase(calendar: .fixedUTC)
        habit = TestFixtures.exercise
    }

    private func interval(days: Int) -> DateInterval {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -days, to: end)!
        return DateInterval(start: start, end: end)
    }

    @Test func zeroDayIntervalProducesZeroRate() {
        let interval = DateInterval(start: Date(), end: Date())
        let rate = sut.execute(habit: habit, completions: [], over: interval)
        #expect(rate == 0.0)
    }

    @Test func noCompletionsProducesZeroRate() {
        let rate = sut.execute(habit: habit, completions: [], over: interval(days: 7))
        #expect(rate == 0.0)
    }

    @Test func perfectCompletionProducesRateOfOne() {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -7, to: end)!
        let interval = DateInterval(start: start, end: end)
        let completions = (0..<7).map { daysAgo -> HabitCompletion in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: end)!
            return HabitCompletion(habitId: habit.id, completedAt: date)
        }
        let rate = sut.execute(habit: habit, completions: completions, over: interval)
        #expect(rate == 1.0)
    }

    @Test func halfCompletionProducesRateOfHalf() {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -10, to: end)!
        let interval = DateInterval(start: start, end: end)
        // Complete only 5 of 10 days
        let completions = (0..<5).map { daysAgo -> HabitCompletion in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: end)!
            return HabitCompletion(habitId: habit.id, completedAt: date)
        }
        let rate = sut.execute(habit: habit, completions: completions, over: interval)
        #expect(rate == 0.5)
    }

    @Test func completionRateIsClampedToOneEvenWithExtraCompletions() {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -3, to: end)!
        let interval = DateInterval(start: start, end: end)
        // More completions than days — rate should not exceed 1.0
        let completions = (0..<3).flatMap { daysAgo -> [HabitCompletion] in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: end)!
            return [
                HabitCompletion(habitId: habit.id, completedAt: date),
                HabitCompletion(habitId: habit.id, completedAt: date.addingTimeInterval(3600))
            ]
        }
        let rate = sut.execute(habit: habit, completions: completions, over: interval)
        #expect(rate <= 1.0)
    }

    @Test func completionsOutsideIntervalAreIgnored() {
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -7, to: end)!
        let interval = DateInterval(start: start, end: end)
        // Only one completion inside + one outside
        let inside = HabitCompletion(habitId: habit.id, completedAt: end.addingTimeInterval(-86400))
        let outside = HabitCompletion(habitId: habit.id, completedAt: start.addingTimeInterval(-86400))
        let rate = sut.execute(habit: habit, completions: [inside, outside], over: interval)
        #expect(rate > 0.0)
        #expect(rate < 1.0)
    }
}
