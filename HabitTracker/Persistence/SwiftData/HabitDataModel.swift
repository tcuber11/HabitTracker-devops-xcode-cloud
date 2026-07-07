import SwiftData
import Foundation

/// SwiftData persistence model for a Habit.
/// Mapped to/from the domain `Habit` struct via conversion helpers.
/// This model lives in the infrastructure layer — the domain layer never imports SwiftData.
@Model
final class HabitDataModel {
    var id: UUID
    var name: String
    var habitDescription: String
    var frequencyData: Data  // JSON-encoded HabitFrequency
    var createdAt: Date
    var isArchived: Bool

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletionDataModel.habit)
    var completions: [HabitCompletionDataModel]

    init(from habit: Habit) throws {
        self.id = habit.id
        self.name = habit.name
        self.habitDescription = habit.habitDescription
        self.frequencyData = try JSONEncoder().encode(habit.frequency)
        self.createdAt = habit.createdAt
        self.isArchived = habit.isArchived
        self.completions = []
    }

    func update(from habit: Habit) throws {
        name = habit.name
        habitDescription = habit.habitDescription
        frequencyData = try JSONEncoder().encode(habit.frequency)
        isArchived = habit.isArchived
    }

    func toHabit() throws -> Habit {
        let frequency = try JSONDecoder().decode(HabitFrequency.self, from: frequencyData)
        return Habit(
            id: id,
            name: name,
            habitDescription: habitDescription,
            frequency: frequency,
            createdAt: createdAt,
            isArchived: isArchived
        )
    }
}
