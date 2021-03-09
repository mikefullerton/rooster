//
//  EventKitEnums.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import Foundation

// swiftlint:disable file_types_order

// this is just here to shut the linter up about the file_name
private enum EventKitEnums {
}

public enum ParticipantStatus: Int, CustomStringConvertible, Codable, Equatable {
    case unknown            = 0
    case pending            = 1
    case accepted           = 2
    case declined           = 3
    case tentative          = 4
    case delegated          = 5
    case completed          = 6
    case inProcess          = 7

    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .pending:
            return "pending"
        case .accepted:
            return "accepted"
        case .declined:
            return "declined"
        case .tentative:
            return "tentative"
        case .delegated:
            return "delegated"
        case .completed:
            return "completed"
        case .inProcess:
            return "inProcess"
        }
    }

    public var isVisibleStatus: Bool {
        switch self {
        case .pending:
            return true

        case .accepted:
            return true

        case .declined:
            return true

        case .tentative:
            return true

        case .unknown:
            return false

        case .delegated:
            return false

        case .completed:
            return false

        case .inProcess:
            return false
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public var isTentative: Bool {
        switch self {
        case .tentative, .pending, .inProcess:
            return true

        case .declined, .accepted, .delegated, .completed, .unknown:
            return false
        }
    }

    public var isAccepted: Bool {
        self == .accepted
    }

    public var isDeclined: Bool {
        self == .declined
    }
}

public enum ParticipantRole: Int, CustomStringConvertible, Codable, Equatable {
    case unknown            = 0
    case required           = 1
    case optional           = 2
    case chair              = 3
    case nonParticipant     = 4

    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .required:
            return "required"
        case .optional:
            return "optional"
        case .chair:
            return "chair"
        case .nonParticipant:
            return "nonParticipant"
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

public enum ParticipantType: Int, CustomStringConvertible, Codable, Equatable {
    case unknown            = 0
    case person             = 1
    case room               = 2
    case resource           = 3
    case group              = 4

    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .person:
            return "person"
        case .room:
            return "room"
        case .resource:
            return "resource"
        case .group:
            return "group"
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
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
