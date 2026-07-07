import Foundation
import Testing
@testable import AcademyHabitTracker

// MARK: - Habit Model Tests

struct HabitModelTests {
    @Test func defaultFrequencyIsDaily() {
        let habit = Habit(name: "Run")
        #expect(habit.frequency == .daily)
    }

    @Test func habitIsNotArchivedByDefault() {
        let habit = Habit(name: "Read")
        #expect(habit.isArchived == false)
    }

    @Test func weekdayFrequencyDisplayName() {
        let freq = HabitFrequency.weekly(days: [.monday, .wednesday, .friday])
        #expect(freq.displayName.contains("Mon"))
        #expect(freq.displayName.contains("Wed"))
        #expect(freq.displayName.contains("Fri"))
    }

    @Test func dailyRequiredCompletionsPerWeekIsSeven() {
        #expect(HabitFrequency.daily.requiredCompletionsPerWeek == 7)
    }

    @Test func weeklyRequiredCompletionsMatchesDayCount() {
        let freq = HabitFrequency.weekly(days: [.monday, .tuesday, .thursday])
        #expect(freq.requiredCompletionsPerWeek == 3)
    }

//    @Test func habitEquality() {
//        let id = UUID()
//        let a = Habit(id: id, name: "Yoga")
//        let b = Habit(id: id, name: "Yoga")
//        #expect(a == b)
//    }

//    @Test func habitInequalityByName() {
//        let id = UUID()
//        let a = Habit(id: id, name: "Yoga")
//        let b = Habit(id: id, name: "Meditation")
//        #expect(a != b)
//    }
}

// MARK: - HabitCompletion Tests

struct HabitCompletionTests {
    @Test func completionHoldsHabitId() {
        let habitId = UUID()
        let completion = HabitCompletion(habitId: habitId)
        #expect(completion.habitId == habitId)
    }

    @Test func completionDefaultDateIsNow() {
        let before = Date()
        let completion = HabitCompletion(habitId: UUID())
        let after = Date()
        #expect(completion.completedAt >= before)
        #expect(completion.completedAt <= after)
    }
}

// MARK: - HabitStatistics Tests

struct HabitStatisticsTests {
    @Test func completionRatePercentRoundsCorrectly() {
        let habit = TestFixtures.exercise
        let stats = HabitStatistics(
            habit: habit,
            currentStreak: 3,
            longestStreak: 5,
            completionRate: 0.667,
            totalCompletions: 20,
            completionsThisWeek: 3,
            completionsThisMonth: 15,
            lastCompletedAt: Date()
        )
        #expect(stats.completionRatePercent == 67)
    }

    @Test func isCompletedTodayReturnsTrueForTodaysCompletion() {
        let habit = TestFixtures.exercise
        let stats = HabitStatistics(
            habit: habit,
            currentStreak: 1,
            longestStreak: 1,
            completionRate: 1.0,
            totalCompletions: 1,
            completionsThisWeek: 1,
            completionsThisMonth: 1,
            lastCompletedAt: Date()
        )
        #expect(stats.isCompletedToday == true)
    }

    @Test func isCompletedTodayReturnsFalseForNilDate() {
        let habit = TestFixtures.exercise
        let stats = HabitStatistics(
            habit: habit,
            currentStreak: 0,
            longestStreak: 0,
            completionRate: 0.0,
            totalCompletions: 0,
            completionsThisWeek: 0,
            completionsThisMonth: 0,
            lastCompletedAt: nil
        )
        #expect(stats.isCompletedToday == false)
    }
}
