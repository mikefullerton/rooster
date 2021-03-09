//
//  RCCalendarItemStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation

// represents the small subset of data we actually store
public struct CalendarStorageRecord: Codable, Equatable {

    public let isSubscribed: Bool

    public init(withCalendar calendar: RCCalendar) {
        self.isSubscribed = calendar.isSubscribed
    }
}

extension RCCalendar {
    var storageRecord: CalendarStorageRecord {
        return CalendarStorageRecord(withCalendar: self)
    }
}
