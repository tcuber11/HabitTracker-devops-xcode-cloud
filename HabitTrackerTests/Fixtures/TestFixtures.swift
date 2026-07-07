import Foundation
@testable import Ch3Group3HabitTrackerDio

// MARK: - Test Fixtures
//
// Shared fixtures used across domain, MV, MVVM, and TCA test suites.
// Follows the Swift Testing Pro guideline of placing fixtures in a dedicated file.

enum TestFixtures {

    // MARK: - Habits

    static func habit(
        id: UUID = UUID(),
        name: String = "Exercise",
        description: String = "Daily workout",
        frequency: HabitFrequency = .daily,
        createdAt: Date = .now
    ) -> Habit {
        Habit(id: id, name: name, habitDescription: description, frequency: frequency, createdAt: createdAt)
    }

    static var exercise: Habit {
        habit(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Exercise")
    }

    static var meditation: Habit {
        habit(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Meditation")
    }

    static var weekdayHabit: Habit {
        habit(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            name: "Weekday Reading",
            frequency: .weekly(days: [.monday, .tuesday, .wednesday, .thursday, .friday])
        )
    }

    // MARK: - Completions

    static func completion(
        habitId: UUID,
        daysAgo: Int = 0,
        calendar: Calendar = .current
    ) -> HabitCompletion {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: calendar.startOfDay(for: Date()))!
        return HabitCompletion(habitId: habitId, completedAt: date)
    }

    /// Creates `count` consecutive daily completions ending today.
    static func consecutiveCompletions(
        for habit: Habit,
        count: Int,
        calendar: Calendar = .current
    ) -> [HabitCompletion] {
        (0..<count).map { daysAgo in
            completion(habitId: habit.id, daysAgo: daysAgo, calendar: calendar)
        }
    }

    // MARK: - Repository

    static func repository(
        habits: [Habit] = [],
        completions: [HabitCompletion] = []
    ) -> InMemoryHabitRepository {
        InMemoryHabitRepository(habits: habits, completions: completions)
    }

    static func repositoryWithHabits() -> InMemoryHabitRepository {
        repository(habits: [exercise, meditation])
    }
}

// MARK: - Calendar Helpers

extension Calendar {
    static var fixedUTC: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal
    }
}

// MARK: - Date Helpers for Tests

extension Date {
    static func daysAgo(_ n: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: -n, to: calendar.startOfDay(for: .now))!
    }
}
