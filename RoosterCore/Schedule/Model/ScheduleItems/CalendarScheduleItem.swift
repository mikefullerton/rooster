//
//  CalendarScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

public struct CalendarScheduleItem: StringIdentifiable, AbstractEquatable, Enableable, Equatable, Identifiable, CustomStringConvertible, Loggable {
    public typealias ID = String

    public let id: String

    public var eventKitCalendar: EventKitCalendar

    public var isEnabled: Bool {
        get { self.storageRecord.isEnabled }
        set { self.storageRecord.isEnabled = newValue }
    }

    public internal(set) var storageRecord: CalendarScheduleItemStorageRecord

    public var description: String {
        """
        \(type(of: self)) \
        calendar: \(self.eventKitCalendar.description) \
        isEnabled == \(self.isEnabled)
        """
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let otherCalendar = scheduleItem as? CalendarScheduleItem else { return false }
        return otherCalendar == self
    }
}
