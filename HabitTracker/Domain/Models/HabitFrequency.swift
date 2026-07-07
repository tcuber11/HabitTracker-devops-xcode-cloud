import Foundation

/// Describes how often a habit should be performed.
/// Architecture-independent value type — no SwiftUI, SwiftData, or framework dependencies.
enum HabitFrequency: Equatable, Codable, Sendable, Hashable {
    case daily
    case weekly(days: Set<Weekday>)

    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly(let days):
            if days.count == 7 { return "Every day" }
            let names = days.sorted { $0.rawValue < $1.rawValue }.map(\.shortName).joined(separator: ", ")
            return "Weekly (\(names))"
        }
    }

    var requiredCompletionsPerWeek: Int {
        switch self {
        case .daily:
            return 7
        case .weekly(let days):
            return days.count
        }
    }
}

// MARK: - Weekday

enum Weekday: Int, CaseIterable, Codable, Sendable, Identifiable, Comparable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .sunday:    return "Sun"
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday:    return "Sunday"
        case .monday:    return "Monday"
        case .tuesday:   return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday:  return "Thursday"
        case .friday:    return "Friday"
        case .saturday:  return "Saturday"
        }
    }

    /// Calendar.weekday value (1 = Sunday in Gregorian calendar).
    var calendarWeekday: Int { rawValue + 1 }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    static func from(date: Date, calendar: Calendar = .current) -> Weekday {
        let weekday = calendar.component(.weekday, from: date) - 1
        return Weekday(rawValue: weekday) ?? .sunday
    }
}
