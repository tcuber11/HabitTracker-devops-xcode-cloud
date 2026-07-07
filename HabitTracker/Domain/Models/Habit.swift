import Foundation

/// The core domain model for a habit.
/// Architecture-independent — pure Swift value type with no framework dependencies.
struct Habit: Identifiable, Equatable, Sendable, Codable, Hashable {
    let id: UUID
    var name: String
    var habitDescription: String
    var frequency: HabitFrequency
    var createdAt: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        habitDescription: String = "",
        frequency: HabitFrequency = .daily,
        createdAt: Date = Date(),
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.habitDescription = habitDescription
        self.frequency = frequency
        self.createdAt = createdAt
        self.isArchived = isArchived
    }
}
