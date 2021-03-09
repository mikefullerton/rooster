//
//  ReminderScheduleItem+StoredData.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct ReminderScheduleItemStorageRecord: ScheduleItemStorageRecord, Equatable, CustomStringConvertible {
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
    public var lengthInMinutes: Int {
        didSet { self.updateModificationDate() }
    }
    public var lastPriorityUpgradeDate: Date? {
        didSet { self.updateModificationDate() }
    }

    public private(set) var modificationDate: Date

    public let creationDate: Date

    public init(isEnabled: Bool,
                startDate: Date?,
                finishedDate: Date?,
                isRecurring: Bool,
                lengthInMinutes: Int,
                lastPriorityUpgradeDate: Date?) {
        self.lengthInMinutes = lengthInMinutes
        self.lastPriorityUpgradeDate = lastPriorityUpgradeDate

        self.isEnabled = isEnabled
        self.startDate = startDate
        self.endDate = nil
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
        lengthInMinutes: \(self.lengthInMinutes), \
        lastPriorityUpgradeDate: \(self.lastPriorityUpgradeDate?.shortDateAndLongTimeString ?? "nil"), \
        creationDate: \(self.creationDate.shortDateAndLongTimeString), \
        modificationDate: \(self.modificationDate.shortDateAndLongTimeString)
        """
    }

    public func isEqual(to record: AbstractEquatable) -> Bool {
        guard let otherEvent = record as? ReminderScheduleItemStorageRecord else { return false }
        return self == otherEvent
    }

    private mutating func updateModificationDate() {
        self.modificationDate = Date()
    }
}

extension ReminderScheduleItemStorageRecord: Codable {
    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case isEnabled
        case finishedDate
        case startDate
        case endDate
        case isRecurring
        case lengthInMinutes
        case lastPriorityUpgradeDate
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
        self.lengthInMinutes = try values.decodeIfPresent(Int.self, forKey: .lengthInMinutes) ?? ReminderScheduleBehavior.defaultLengthInMinutes
        self.lastPriorityUpgradeDate = try values.decodeIfPresent(Date.self, forKey: .lastPriorityUpgradeDate)
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
        try container.encode(self.lengthInMinutes, forKey: .lengthInMinutes)
        try container.encode(self.lastPriorityUpgradeDate, forKey: .lastPriorityUpgradeDate)
        try container.encode(self.modificationDate, forKey: .modificationDate)
        try container.encode(self.creationDate, forKey: .creationDate)
    }
}

extension ReminderScheduleItem {
    public static func createStorageRecord(withEventKitReminder reminder: EventKitReminder,
                                           scheduleBehavior: ScheduleBehavior) -> ReminderScheduleItemStorageRecord {
        ReminderScheduleItemStorageRecord(isEnabled: true,
                                          startDate: reminder.scheduleStartDate,
                                          finishedDate: nil,
                                          isRecurring: reminder.isRecurring,
                                          lengthInMinutes: scheduleBehavior.reminderScheduleBehavior.defaultLengthInMinutes,
                                          lastPriorityUpgradeDate: nil)
    }
}
