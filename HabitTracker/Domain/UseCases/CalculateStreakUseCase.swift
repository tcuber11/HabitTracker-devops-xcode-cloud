import Foundation

/// Result returned by streak calculation.
struct StreakResult: Equatable, Sendable {
    let current: Int
    let longest: Int
}

/// Calculates current and longest streaks for a habit given its completion history.
///
/// This is a pure computation — no async, no I/O, no framework dependencies.
/// The `calendar` dependency is injected so tests can provide a fixed calendar.
struct CalculateStreakUseCase: Sendable {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func execute(
        habit: Habit,
        completions: [HabitCompletion],
        from date: Date = Date()
    ) -> StreakResult {
        switch habit.frequency {
        case .daily:
            return calculateDailyStreak(completions: completions, from: date)
        case .weekly(let days):
            return calculateWeeklyStreak(completions: completions, requiredDays: days, from: date)
        }
    }

    // MARK: - Daily Streak

    private func calculateDailyStreak(
        completions: [HabitCompletion],
        from date: Date
    ) -> StreakResult {
        let completedDays = Set(completions.map { calendar.startOfDay(for: $0.completedAt) })
        let current = countCurrentDailyStreak(completedDays: completedDays, from: date)
        let longest = countLongestDailyStreak(completedDays: completedDays)
        return StreakResult(current: current, longest: max(current, longest))
    }

    private func countCurrentDailyStreak(completedDays: Set<Date>, from date: Date) -> Int {
        var streak = 0
        var check = calendar.startOfDay(for: date)
        while completedDays.contains(check) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: check) else { break }
            check = previous
        }
        return streak
    }

    private func countLongestDailyStreak(completedDays: Set<Date>) -> Int {
        guard !completedDays.isEmpty else { return 0 }
        let sorted = completedDays.sorted()
        var longest = 1
        var current = 1
        for index in 1..<sorted.count {
            let previous = sorted[index - 1]
            let expected = calendar.date(byAdding: .day, value: 1, to: previous)!
            if calendar.isDate(sorted[index], inSameDayAs: expected) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    // MARK: - Weekly Streak

    /// A week "counts" only when every required weekday has at least one completion.
    private func calculateWeeklyStreak(
        completions: [HabitCompletion],
        requiredDays: Set<Weekday>,
        from date: Date
    ) -> StreakResult {
        guard !requiredDays.isEmpty else { return StreakResult(current: 0, longest: 0) }
        let completedDays = Set(completions.map { calendar.startOfDay(for: $0.completedAt) })

        // Gather week-start dates for each completion, then check completeness.
        let current = countCurrentWeeklyStreak(completedDays: completedDays, requiredDays: requiredDays, from: date)
        let longest = countLongestWeeklyStreak(completedDays: completedDays, requiredDays: requiredDays)
        return StreakResult(current: current, longest: max(current, longest))
    }

    private func weekStart(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    private func isWeekComplete(weekStartDate: Date, requiredDays: Set<Weekday>, completedDays: Set<Date>) -> Bool {
        requiredDays.allSatisfy { weekday in
            guard let target = calendar.date(
                bySetting: .weekday,
                value: weekday.calendarWeekday,
                of: weekStartDate
            ) else { return false }
            return completedDays.contains(calendar.startOfDay(for: target))
        }
    }

    private func countCurrentWeeklyStreak(
        completedDays: Set<Date>,
        requiredDays: Set<Weekday>,
        from date: Date
    ) -> Int {
        var streak = 0
        var week = weekStart(for: date)
        while isWeekComplete(weekStartDate: week, requiredDays: requiredDays, completedDays: completedDays) {
            streak += 1
            guard let prev = calendar.date(byAdding: .weekOfYear, value: -1, to: week) else { break }
            week = prev
        }
        return streak
    }

    private func countLongestWeeklyStreak(
        completedDays: Set<Date>,
        requiredDays: Set<Weekday>
    ) -> Int {
        guard let earliest = completedDays.min() else { return 0 }
        var longest = 0
        var current = 0
        var week = weekStart(for: earliest)
        let today = calendar.startOfDay(for: Date())
        while week <= today {
            if isWeekComplete(weekStartDate: week, requiredDays: requiredDays, completedDays: completedDays) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 0
            }
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: week) else { break }
            week = next
        }
        return longest
    }
}
