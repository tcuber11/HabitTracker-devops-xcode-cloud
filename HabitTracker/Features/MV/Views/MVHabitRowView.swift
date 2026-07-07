import SwiftUI

/// MV Architecture — a single row in the habit list.
/// Extracted into its own type as required by SwiftUI-Pro guidelines.
struct MVHabitRowView: View {
    let habit: Habit
    let statistics: HabitStatistics?

    var body: some View {
        HStack(spacing: 12) {
            completionIndicator
            habitInfo
            Spacer()
            streakBadge
        }
        .padding(.vertical, 4)
    }

    private var completionIndicator: some View {
        Image(systemName: statistics?.isCompletedToday == true ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .foregroundStyle(statistics?.isCompletedToday == true ? .green : .secondary)
    }

    private var habitInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(habit.name)
                .font(.headline)
            Text(habit.frequency.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var streakBadge: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let stats = statistics, stats.currentStreak > 0 {
                Label("\(stats.currentStreak)", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            if let stats = statistics {
                Text("\(stats.completionRatePercent)%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
