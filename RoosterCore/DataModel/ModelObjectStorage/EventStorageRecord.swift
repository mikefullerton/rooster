//
//  RCCalendarItemStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/16/21.
//

import Foundation

// represents the small subset of data we actually store
public struct EventStorageRecord: Codable, Equatable {

    public let isSubscribed: Bool
    public let alarm: RCAlarm
    public let startDate: Date
    public let endDate: Date
    public let isRecurring: Bool

    public init(withEvent event: RCEvent) {
        self.isSubscribed = event.isSubscribed
        self.alarm = event.alarm
        self.endDate = event.startDate
        self.startDate = event.endDate
        self.isRecurring = event.isRecurring
    }
}

extension RCEvent {
    var storageRecord: EventStorageRecord {
        return EventStorageRecord(withEvent: self)
    }
}
