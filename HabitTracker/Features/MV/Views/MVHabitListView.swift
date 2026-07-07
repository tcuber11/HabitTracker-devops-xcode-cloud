import SwiftUI

/// MV Architecture — Habit list.
///
/// Reads all state directly from the injected `HabitStore`.
/// There is no ViewModel — the store IS the model layer that SwiftUI observes.
/// This demonstrates how far @Observable can scale without adding a ViewModel.
struct MVHabitListView: View {
    @Environment(HabitStore.self) private var store
    @State private var isShowingAddHabit = false

    var body: some View {
        Group {
            if store.habits.isEmpty && !store.isLoading {
                MVEmptyStateView()
            } else {
                habitList
            }
        }
        .navigationTitle("Habits (MV)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Habit", systemImage: "plus", action: showAddHabit)
            }
        }
        .sheet(isPresented: $isShowingAddHabit) {
            MVAddHabitView()
        }
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
    }

    private var habitList: some View {
        List {
            ForEach(store.habits) { habit in
                NavigationLink(value: habit) {
                    MVHabitRowView(
                        habit: habit,
                        statistics: store.statistics[habit.id]
                    )
                }
            }
            .onDelete(perform: deleteHabits)
        }
    }

    private func showAddHabit() {
        isShowingAddHabit = true
    }

    private func deleteHabits(at offsets: IndexSet) {
        Task {
            await store.deleteHabits(at: offsets)
        }
    }
}
