import SwiftData
import Foundation

/// SwiftData-backed implementation of `HabitRepository`.
/// Owned by the infrastructure layer. Domain and architecture layers depend only on the protocol.
final class SwiftDataHabitRepository: HabitRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Habits

    func fetchHabits() async throws -> [Habit] {
        let descriptor = FetchDescriptor<HabitDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toHabit() }
    }

    func saveHabit(_ habit: Habit) async throws {
        let descriptor = FetchDescriptor<HabitDataModel>(
            predicate: #Predicate { $0.id == habit.id }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            try existing.update(from: habit)
        } else {
            let model = try HabitDataModel(from: habit)
            modelContext.insert(model)
        }
        try modelContext.save()
    }

    func deleteHabit(id: UUID) async throws {
        let descriptor = FetchDescriptor<HabitDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw HabitError.habitNotFound(id)
        }
        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Completions

    func fetchCompletions(for habitId: UUID) async throws -> [HabitCompletion] {
        let descriptor = FetchDescriptor<HabitCompletionDataModel>(
            predicate: #Predicate { $0.habitId == habitId },
            sortBy: [SortDescriptor(\.completedAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { $0.toCompletion() }
    }

    func fetchAllCompletions() async throws -> [HabitCompletion] {
        let descriptor = FetchDescriptor<HabitCompletionDataModel>(
            sortBy: [SortDescriptor(\.completedAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor).map { $0.toCompletion() }
    }

    func saveCompletion(_ completion: HabitCompletion) async throws {
        let habitDescriptor = FetchDescriptor<HabitDataModel>(
            predicate: #Predicate { $0.id == completion.habitId }
        )
        guard let habit = try modelContext.fetch(habitDescriptor).first else {
            throw HabitError.habitNotFound(completion.habitId)
        }
        let model = HabitCompletionDataModel(from: completion)
        model.habit = habit
        modelContext.insert(model)
        try modelContext.save()
    }

    func deleteCompletion(id: UUID) async throws {
        let descriptor = FetchDescriptor<HabitCompletionDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw HabitError.completionNotFound(id)
        }
        modelContext.delete(model)
        try modelContext.save()
    }
}

// MARK: - Container Factory

extension ModelContainer {
    /// Shared container for production use.
    static var habitTracker: ModelContainer = {
        let schema = Schema([HabitDataModel.self, HabitCompletionDataModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: config)
    }()

    /// In-memory container for SwiftUI Previews.
    static var preview: ModelContainer = {
        let schema = Schema([HabitDataModel.self, HabitCompletionDataModel.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: config)
    }()
}
