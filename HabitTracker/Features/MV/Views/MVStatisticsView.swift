import SwiftUI

/// MV Architecture — statistics overview screen.
/// Reads all data directly from the store — no ViewModel intermediary.
struct MVStatisticsView: View {
    @Environment(HabitStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading {
                    ProgressView()
                } else if store.habits.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.bar",
                        description: Text("Add and complete habits to see statistics.")
                    )
                } else {
                    statisticsList
                }
            }
            .navigationTitle("Statistics (MV)")
        }
    }

    private var statisticsList: some View {
        List {
            MVOverviewSection(store: store)
            MVHabitBreakdownSection(habitStatistics: store.habits.compactMap { store.statistics[$0.id] })
        }
    }
}

struct MVOverviewSection: View {
    let store: HabitStore

    private var allStats: [HabitStatistics] {
        store.habits.compactMap { store.statistics[$0.id] }
    }

    private var totalCompletionsToday: Int {
        allStats.filter { $0.isCompletedToday }.count
    }

    private var averageCompletionRate: Double {
        guard !allStats.isEmpty else { return 0 }
        return allStats.reduce(0) { $0 + $1.completionRate } / Double(allStats.count)
    }

    private var topStreakHabit: HabitStatistics? {
        allStats.max { $0.currentStreak < $1.currentStreak }
    }

    var body: some View {
        Section("Overview") {
            LabeledContent("Completed Today") {
                Text("\(totalCompletionsToday)").foregroundStyle(.green)
            }
            LabeledContent("Avg. Completion Rate (30d)") {
                Text("\(Int((averageCompletionRate * 100).rounded()))%")
            }
            if let top = topStreakHabit {
                LabeledContent("Longest Active Streak") {
                    Label("\(top.currentStreak) days — \(top.habit.name)", systemImage: "flame.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

struct MVHabitBreakdownSection: View {
    let habitStatistics: [HabitStatistics]

    var body: some View {
        Section("Habits") {
            ForEach(habitStatistics, id: \.habit.id) { stats in
                MVStatisticsRowView(statistics: stats)
            }
        }
    }
}

struct MVStatisticsRowView: View {
    let statistics: HabitStatistics

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(statistics.habit.name).font(.headline)
                Spacer()
                Label("\(statistics.currentStreak)", systemImage: "flame.fill")
                    .font(.caption).foregroundStyle(.orange)
            }
            ProgressView(value: statistics.completionRate).tint(.blue)
            Text("\(statistics.completionRatePercent)% completion rate (30 days)")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
