//
//  DataModelStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation

public struct DataModelStorageRecord: Codable, Equatable {
    public static let version:Int = 1
    
    public let version: Int
    public var calendars: [String: CalendarStorageRecord]
    public var delegateCalendars: [String: CalendarStorageRecord]
    public var events: [String: CalendarItemStorageRecord]
    public var reminders: [String: CalendarItemStorageRecord]
    
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

        var events: [String: CalendarItemStorageRecord] = [:]
        dataModel.events.forEach {
            events[$0.id] = CalendarItemStorageRecord(withCalendarItem: $0)
        }
        
        var reminders: [String: CalendarItemStorageRecord] = [:]
        dataModel.reminders.forEach {
            reminders[$0.id] = CalendarItemStorageRecord(withCalendarItem: $0)
        }
        
        self.calendars = calendarsList
        self.delegateCalendars = delegateList
        self.events = events
        self.reminders = reminders
    }
    
    public static func == (lhs: DataModelStorageRecord, rhs: DataModelStorageRecord) -> Bool {
        return  lhs.version == rhs.version &&
                lhs.calendars == rhs.calendars &&
                lhs.delegateCalendars == rhs.delegateCalendars &&
                lhs.events == rhs.events &&
                lhs.reminders == rhs.reminders
    }
    
    
    
}

extension RCCalendarDataModel {
    var storageRecord: DataModelStorageRecord {
        return DataModelStorageRecord(withDataModel: self)
    }
}
