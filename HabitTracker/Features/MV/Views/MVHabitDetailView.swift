import SwiftUI

/// MV Architecture — habit detail and inline statistics.
///
/// State flows down from the store: the view reads the current habit
/// from the environment and triggers store actions for mutations.
/// No local ViewModel is needed — the store provides all necessary context.
struct MVHabitDetailView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    private var statistics: HabitStatistics? {
        store.statistics[habit.id]
    }

    var body: some View {
        List {
            habitSection
            statisticsSection
            completionSection
        }
        .navigationTitle(habit.name)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var habitSection: some View {
        Section("Details") {
            LabeledContent("Frequency", value: habit.frequency.displayName)
            if !habit.habitDescription.isEmpty {
                Text(habit.habitDescription)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statisticsSection: some View {
        Section("Statistics") {
            if let stats = statistics {
                MVStatisticsGridView(statistics: stats)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var completionSection: some View {
        Section {
            Button(
                statistics?.isCompletedToday == true ? "Completed Today ✓" : "Mark as Complete",
                action: markComplete
            )
            .disabled(statistics?.isCompletedToday == true)
            .frame(maxWidth: .infinity)
            .tint(statistics?.isCompletedToday == true ? .green : .accentColor)
        }
    }

    private func markComplete() {
        Task {
            await store.completeHabit(habit)
        }
    }
}
