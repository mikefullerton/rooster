//
//  Reminder.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import Foundation

// swiftlint:disable file_types_order

public protocol Reminder: CalendarItem {
    var timeZone: TimeZone? { get }

    var startDate: Date? { get }

    var dueDate: Date? { get }

    var isCompleted: Bool { get }

    var completionDate: Date? { get }

    var priority: ReminderPriority { get }
}

public enum ReminderPriority: Int, CustomStringConvertible, Codable, Equatable, Comparable {
    case none               = 0
    case high               = 1
    case medium             = 5
    case low                = 9

    public var description: String {
        switch self {
        case .none:
            return "none"
        case .high:
            return "high"
        case .medium:
            return "medium"
        case .low:
            return "low"
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func < (lhs: ReminderPriority, rhs: ReminderPriority) -> Bool {
        guard lhs != rhs else {
            return false
        }

        if lhs == .none {
            return true
        }

        if rhs == .none {
            return false
        }

        return lhs.rawValue > rhs.rawValue // priorties are inverted
    }

    public var increased: ReminderPriority {
        switch self {
        case .none:
            return .low

        case .high:
            return .high

        case .medium:
            return .high

        case .low:
            return .medium
        }
    }
}
