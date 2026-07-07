import SwiftUI

/// MV Architecture — root navigation view.
/// Injects the HabitStore into the SwiftUI environment once.
/// All child views read state directly from the store — no ViewModels required.
struct MVRootView: View {
    @State private var store: HabitStore

    init(repository: any HabitRepository) {
        _store = State(initialValue: HabitStore(repository: repository))
    }

    var body: some View {
        TabView {
            Tab("Habits", systemImage: "checkmark.circle") {
                NavigationStack {
                    MVHabitListView()
                        .navigationDestination(for: Habit.self) { habit in
                            MVHabitDetailView(habit: habit)
                        }
                }
            }
            Tab("Statistics", systemImage: "chart.bar") {
                MVStatisticsView()
            }
        }
        .environment(store)
        .task {
            await store.loadHabits()
        }
        .alert(
            "Error",
            isPresented: Binding(get: { store.error != nil }, set: { if !$0 { store.clearError() } })
        ) {
        } message: {
            Text(store.error?.localizedDescription ?? "")
        }
    }
}
