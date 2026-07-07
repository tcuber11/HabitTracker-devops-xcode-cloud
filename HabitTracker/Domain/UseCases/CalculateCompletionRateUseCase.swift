import Foundation

/// Calculates the ratio of actual completions to expected completions over a date interval.
///
/// Pure computation — no I/O, no framework dependencies.
struct CalculateCompletionRateUseCase: Sendable {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// - Parameters:
    ///   - habit: The habit whose rate is being computed.
    ///   - completions: All completions for this habit (may be unfiltered).
    ///   - interval: The period over which to measure. Only completions inside this interval count.
    /// - Returns: A value in [0.0, 1.0], where 1.0 means every expected day was completed.
    func execute(
        habit: Habit,
        completions: [HabitCompletion],
        over interval: DateInterval
    ) -> Double {
        let expected = expectedCompletions(for: habit.frequency, over: interval)
        guard expected > 0 else { return 0 }
        let actual = completions.filter { interval.contains($0.completedAt) }
        let uniqueDays = Set(actual.map { calendar.startOfDay(for: $0.completedAt) })
        return min(1.0, Double(uniqueDays.count) / Double(expected))
    }

    // MARK: - Private

    private func expectedCompletions(for frequency: HabitFrequency, over interval: DateInterval) -> Int {
        switch frequency {
        case .daily:
            return dayCount(in: interval)
        case .weekly(let days):
            return weekdayCount(days, in: interval)
        }
    }

    private func dayCount(in interval: DateInterval) -> Int {
        let start = calendar.startOfDay(for: interval.start)
        let end = calendar.startOfDay(for: interval.end)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    private func weekdayCount(_ days: Set<Weekday>, in interval: DateInterval) -> Int {
        var count = 0
        var current = calendar.startOfDay(for: interval.start)
        let endDay = calendar.startOfDay(for: interval.end)
        while current < endDay {
            let weekday = Weekday.from(date: current, calendar: calendar)
            if days.contains(weekday) { count += 1 }
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return count
    }
}
