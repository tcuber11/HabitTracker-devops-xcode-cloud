import Foundation

/// Orchestrates streak and completion-rate calculations to produce a full `HabitStatistics` snapshot.
///
/// This is the only use case that performs I/O (via the repository) to gather completions.
/// All subsequent calculations are delegated to pure use cases.
struct GenerateStatisticsUseCase: Sendable {
    let repository: any HabitRepository
    let calculateStreak: CalculateStreakUseCase
    let calculateCompletionRate: CalculateCompletionRateUseCase

    init(
        repository: any HabitRepository,
        calendar: Calendar = .current
    ) {
        self.repository = repository
        self.calculateStreak = CalculateStreakUseCase(calendar: calendar)
        self.calculateCompletionRate = CalculateCompletionRateUseCase(calendar: calendar)
    }

    func execute(habit: Habit, from date: Date = Date()) async throws -> HabitStatistics {
        let completions = try await repository.fetchCompletions(for: habit.id)
        let calendar = calculateStreak.calendar

        // Streak
        let streak = calculateStreak.execute(habit: habit, completions: completions, from: date)

        // Completion rate over last 30 days
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: date) ?? date
        let thirtyDayInterval = DateInterval(start: thirtyDaysAgo, end: date)
        let completionRate = calculateCompletionRate.execute(
            habit: habit,
            completions: completions,
            over: thirtyDayInterval
        )

        // This week
        let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let weekStart = calendar.date(from: weekComponents) ?? date
        let weekInterval = DateInterval(start: weekStart, end: date)
        let completionsThisWeek = completions.filter { weekInterval.contains($0.completedAt) }.count

        // This month
        let monthComponents = calendar.dateComponents([.year, .month], from: date)
        let monthStart = calendar.date(from: monthComponents) ?? date
        let monthInterval = DateInterval(start: monthStart, end: date)
        let completionsThisMonth = completions.filter { monthInterval.contains($0.completedAt) }.count

        let lastCompleted = completions.max { $0.completedAt < $1.completedAt }?.completedAt

        return HabitStatistics(
            habit: habit,
            currentStreak: streak.current,
            longestStreak: streak.longest,
            completionRate: completionRate,
            totalCompletions: completions.count,
            completionsThisWeek: completionsThisWeek,
            completionsThisMonth: completionsThisMonth,
            lastCompletedAt: lastCompleted
        )
    }
}
