import SwiftUI

/// MV Architecture — empty state placeholder.
struct MVEmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No Habits Yet",
            systemImage: "checkmark.circle",
            description: Text("Tap + to add your first habit and start tracking your progress.")
        )
    }
}
