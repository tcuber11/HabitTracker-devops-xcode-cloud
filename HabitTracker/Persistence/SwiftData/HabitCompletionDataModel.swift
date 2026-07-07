import SwiftData
import Foundation

/// SwiftData persistence model for a HabitCompletion.
@Model
final class HabitCompletionDataModel {
    var id: UUID
    var habitId: UUID
    var completedAt: Date
    var note: String

    var habit: HabitDataModel?

    init(from completion: HabitCompletion) {
        self.id = completion.id
        self.habitId = completion.habitId
        self.completedAt = completion.completedAt
        self.note = completion.note
    }

    func toCompletion() -> HabitCompletion {
        HabitCompletion(
            id: id,
            habitId: habitId,
            completedAt: completedAt,
            note: note
        )
    }
}
