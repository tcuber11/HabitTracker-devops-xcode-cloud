import Foundation

/// Domain-layer errors. No framework dependencies.
enum HabitError: Error, LocalizedError, Equatable, Sendable {
    case emptyName
    case alreadyCompletedToday
    case habitNotFound(UUID)
    case completionNotFound(UUID)
    case persistence(String)

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Habit name cannot be empty."
        case .alreadyCompletedToday:
            return "This habit has already been completed today."
        case .habitNotFound(let id):
            return "Habit with id \(id) was not found."
        case .completionNotFound(let id):
            return "Completion with id \(id) was not found."
        case .persistence(let message):
            return "Persistence error: \(message)"
        }
    }
}
