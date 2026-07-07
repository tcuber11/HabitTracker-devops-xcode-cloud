import Foundation

/// Aggregated statistics for a single habit.
/// Computed by GenerateStatisticsUseCase — pure value type, no framework dependencies.
struct HabitStatistics: Equatable, Sendable {
    let habit: Habit
    let currentStreak: Int
    let longestStreak: Int

    /// Completion rate over the last 30 days (0.0 – 1.0).
    let completionRate: Double

    let totalCompletions: Int
    let completionsThisWeek: Int
    let completionsThisMonth: Int
    let lastCompletedAt: Date?

    var completionRatePercent: Int {
        Int((completionRate * 100).rounded())
    }

    var isCompletedToday: Bool {
        guard let last = lastCompletedAt else { return false }
        return Calendar.current.isDateInToday(last)
    }
}
