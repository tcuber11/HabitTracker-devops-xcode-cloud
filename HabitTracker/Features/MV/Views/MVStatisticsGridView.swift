import SwiftUI

/// MV Architecture — statistics grid displayed inside habit detail.
struct MVStatisticsGridView: View {
    let statistics: HabitStatistics

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            MVStatCell(value: "\(statistics.currentStreak)", label: "Streak", icon: "flame.fill", color: .orange)
            MVStatCell(value: "\(statistics.longestStreak)", label: "Best", icon: "trophy.fill", color: .yellow)
            MVStatCell(value: "\(statistics.completionRatePercent)%", label: "Rate (30d)", icon: "chart.bar.fill", color: .blue)
            MVStatCell(value: "\(statistics.totalCompletions)", label: "Total", icon: "checkmark.circle.fill", color: .green)
            MVStatCell(value: "\(statistics.completionsThisWeek)", label: "This Week", icon: "calendar", color: .purple)
            MVStatCell(value: "\(statistics.completionsThisMonth)", label: "This Month", icon: "calendar.badge.checkmark", color: .teal)
        }
        .padding(.vertical, 4)
    }
}

/// A single statistic cell.
struct MVStatCell: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
