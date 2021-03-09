//
//  Event.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import Foundation

// swiftlint:disable file_types_order

public protocol Event: CalendarItem {
    var organizer: EventKitParticipant? { get }

    var occurenceDate: Date? { get }

    var timeZone: TimeZone? { get }

    var birthdayContactIdentifier: String? { get }

    var status: EventStatus { get }

    var startDate: Date { get }

    var endDate: Date { get }

    var participationStatus: ParticipantStatus { get }

    var allowsParticipationStatusModifications: Bool { get }

    var availability: EventAvailability { get }
}

public enum EventRecurrenceFrequency: Int, CustomStringConvertible, Codable {
    case daily              = 0
    case weekly             = 1
    case monthly            = 2
    case yearly             = 3

    public var description: String {
        switch self {
        case .daily:
            return "daily"
        case .weekly:
            return "weekly"
        case .monthly:
            return "monthly"
        case .yearly:
            return "yearly"
        }
    }
}

public enum EventAvailability: Int, CustomStringConvertible, Codable {
    case notSupported = -1
    case busy = 0
    case free = 1
    case tentative = 2
    case unavailable = 3

    public var description: String {
        switch self {
        case .notSupported:
            return "notSupported"
        case .busy:
            return "busy"
        case .free:
            return "free"
        case .tentative:
            return "tentative"
        case .unavailable:
            return "unavailable"
        }
    }
}

public enum EventStatus: Int, CustomStringConvertible, Codable {
    case none = 0
    case confirmed = 1
    case tentative = 2
    case canceled = 3

    public var description: String {
        switch self {
        case .none:
            return "none"
        case .confirmed:
            return "confirmed"
        case .tentative:
            return "tentative"
        case .canceled:
            return "canceled"
        }
    }
}
