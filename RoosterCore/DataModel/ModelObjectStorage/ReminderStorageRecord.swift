//
//  RCCalendarItemStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/16/21.
//

import Foundation

// represents the small subset of data we actually store
public struct ReminderStorageRecord: Codable, Equatable {

    public let isSubscribed: Bool
    public let alarm: RCAlarm
    public let startDate: Date?
    public let dueDate: Date?
    public let endDate: Date?
    public let length: TimeInterval
    
    public init(withReminder reminder: RCReminder) {
        self.isSubscribed = reminder.isSubscribed
        self.alarm = reminder.alarm
        self.endDate = reminder.startDate
        self.startDate = reminder.endDate
        self.dueDate = reminder.dueDate
        self.length = reminder.length
    }
}

extension RCReminder {
    var storageRecord: ReminderStorageRecord {
        return ReminderStorageRecord(withReminder: self)
    }
}
