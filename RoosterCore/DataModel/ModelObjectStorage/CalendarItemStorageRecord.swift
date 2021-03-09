//
//  RCCalendarItemStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/16/21.
//

import Foundation

// represents the small subset of data we actually store
public struct CalendarItemStorageRecord: Codable, Equatable {

    public let isSubscribed: Bool
    public let alarm: RCAlarm
    public let startDate: Date
    public let endDate: Date
    public let isRecurring: Bool

    public init(withCalendarItem calendarItem: RCCalendarItem) {
        self.isSubscribed = calendarItem.isSubscribed
        self.alarm = calendarItem.alarm
        self.endDate = calendarItem.endDate
        self.startDate = calendarItem.startDate
        self.isRecurring = calendarItem.isRecurring
    }
    
    public static func == (lhs: CalendarItemStorageRecord, rhs: CalendarItemStorageRecord) -> Bool {
        return  lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.startDate == rhs.startDate &&
                lhs.endDate == rhs.endDate &&
                lhs.isRecurring == rhs.isRecurring
    }
}

extension RCCalendarItem {
    var storageRecord: CalendarItemStorageRecord {
        return CalendarItemStorageRecord(withCalendarItem: self)
    }
}
