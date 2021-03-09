//
//  EventScheduleItem+StoredData.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct EventScheduleItemStorageRecord: ScheduleItemStorageRecord, Equatable, CustomStringConvertible {
    public var isEnabled: Bool {
        didSet { self.updateModificationDate() }
    }
    public var finishedDate: Date? {
        didSet { self.updateModificationDate() }
    }
    public var startDate: Date? {
        didSet { self.updateModificationDate() }
    }
    public var endDate: Date? {
        didSet { self.updateModificationDate() }
    }
    public var isRecurring: Bool {
        didSet { self.updateModificationDate() }
    }

    public private(set) var modificationDate: Date

    public let creationDate: Date

    public static var `default`: EventScheduleItemStorageRecord {
        EventScheduleItemStorageRecord(isEnabled: true,
                                       startDate: nil,
                                       endDate: nil,
                                       finishedDate: nil,
                                       isRecurring: false)
    }

    public init(isEnabled: Bool,
                startDate: Date?,
                endDate: Date?,
                finishedDate: Date?,
                isRecurring: Bool) {
        self.isEnabled = isEnabled
        self.startDate = startDate
        self.endDate = endDate
        self.finishedDate = finishedDate
        self.isRecurring = isRecurring
        let now = Date()
        self.creationDate = now
        self.modificationDate = now
    }

    public var description: String {
        """
        \(type(of: self)): \
        isEnabled: \(isEnabled), \
        startDate: \(startDate?.shortDateAndTimeString ?? "nil"), \
        endDate: \(endDate?.shortDateAndTimeString ?? "nil"), \
        finishedDate: \(finishedDate?.shortDateAndTimeString ?? "nil"), \
        isRecurring: \(isRecurring), \
        creationDate: \(self.creationDate.shortDateAndLongTimeString), \
        modificationDate: \(self.modificationDate.shortDateAndLongTimeString)
        """
    }

    public func isEqual(to record: AbstractEquatable) -> Bool {
        guard let otherEvent = record as? EventScheduleItemStorageRecord else { return false }
        return self == otherEvent
    }

    private mutating func updateModificationDate() {
        self.modificationDate = Date()
    }
}

extension EventScheduleItemStorageRecord: Codable {
    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case isEnabled
        case finishedDate
        case startDate
        case endDate
        case isRecurring
        case creationDate
        case modificationDate
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.finishedDate = try values.decodeIfPresent(Date.self, forKey: .finishedDate)
        self.startDate = try values.decodeIfPresent(Date.self, forKey: .startDate)
        self.endDate = try values.decodeIfPresent(Date.self, forKey: .endDate)
        self.isRecurring = try values.decodeIfPresent(Bool.self, forKey: .isRecurring) ?? false
        self.creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        self.modificationDate = try values.decodeIfPresent(Date.self, forKey: .modificationDate) ?? Date()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isEnabled, forKey: .isEnabled)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
        try container.encode(self.finishedDate, forKey: .finishedDate)
        try container.encode(self.isRecurring, forKey: .isRecurring)
        try container.encode(self.modificationDate, forKey: .modificationDate)
        try container.encode(self.creationDate, forKey: .creationDate)
    }
}

extension EventScheduleItem {
    public static func createStorageRecord(withEventKitEvent event: EventKitEvent,
                                           scheduleBehavior: ScheduleBehavior) -> EventScheduleItemStorageRecord {
        EventScheduleItemStorageRecord(isEnabled: true,
                                       startDate: event.startDate,
                                       endDate: event.endDate,
                                       finishedDate: nil,
                                       isRecurring: event.isRecurring)
    }
}
