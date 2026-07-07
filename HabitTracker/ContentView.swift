import SwiftUI
import SwiftData

// MARK: - App Entry Point

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ArchitectureSelectorView()
                .modelContainer(ModelContainer.habitTracker)
        }
    }
}

// MARK: - Architecture Selector

/// Top-level view that lets you explore all three architecture implementations
/// side-by-side in the same app, using the same shared persistence layer.
struct ArchitectureSelectorView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        MVStack(modelContext: modelContext)
    }
}

// MARK: - Architecture Stacks
// Each stack constructs its own repository from the shared ModelContext.
// All three architectures share the same underlying SwiftData store —
// a key property of the domain-layer abstraction.

struct MVStack: View {
    let modelContext: ModelContext
    var body: some View {
        MVRootView(repository: SwiftDataHabitRepository(modelContext: modelContext))
    }
}

// MARK: - Preview

#Preview {
    ArchitectureSelectorView()
        .modelContainer(ModelContainer.preview)
}
