import Foundation

/// Records a single completion event for a habit on a specific date.
/// Architecture-independent value type.
struct HabitCompletion: Identifiable, Equatable, Sendable, Codable, Hashable {
    let id: UUID
    let habitId: UUID
    let completedAt: Date
    let note: String

    init(
        id: UUID = UUID(),
        habitId: UUID,
        completedAt: Date = Date(),
        note: String = ""
    ) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
        self.note = note
    }
}
