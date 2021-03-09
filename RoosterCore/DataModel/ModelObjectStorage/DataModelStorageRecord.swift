//
//  DataModelStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation

public struct DataModelStorageRecord: Codable, Equatable {
    public static let version:Int = 2
    
    public let version: Int
    public var calendars: [String: CalendarStorageRecord]
    public var delegateCalendars: [String: CalendarStorageRecord]
    public var events: [String: EventStorageRecord]
    public var reminders: [String: ReminderStorageRecord]
    
    public init(withDataModel dataModel: RCCalendarDataModel) {
        
        self.version = Self.version
        
        var calendarsList:[String: CalendarStorageRecord] = [:]
        for calendars in dataModel.calendars.values {
            calendars.forEach {
                calendarsList[$0.id] = CalendarStorageRecord(withCalendar: $0)
            }
        }

        var delegateList:[String: CalendarStorageRecord] = [:]
        for calendars in dataModel.delegateCalendars.values {
            calendars.forEach {
                delegateList[$0.id] = CalendarStorageRecord(withCalendar: $0)
            }
        }

        var events: [String: EventStorageRecord] = [:]
        dataModel.events.forEach {
            events[$0.id] = $0.storageRecord
        }
        
        var reminders: [String: ReminderStorageRecord] = [:]
        dataModel.reminders.forEach {
            reminders[$0.id] = $0.storageRecord
        }
        
        self.calendars = calendarsList
        self.delegateCalendars = delegateList
        self.events = events
        self.reminders = reminders
    }
}

extension RCCalendarDataModel {
    var storageRecord: DataModelStorageRecord {
        return DataModelStorageRecord(withDataModel: self)
    }
}
