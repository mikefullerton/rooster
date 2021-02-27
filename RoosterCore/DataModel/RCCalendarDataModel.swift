//
//  RCCalendarDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

public typealias CalendarSource = String
public typealias CalendarID = String

public struct RCCalendarDataModel : CustomStringConvertible {

    public let calendars: [CalendarSource: [RCCalendar]]
    public let delegateCalendars: [CalendarSource: [RCCalendar]]
    public let events: [RCEvent]
    public let reminders: [RCReminder]
    public let calendarLookup: [CalendarID: RCCalendar]
    
    public let allItems: [RCCalendarItem]
        
    init(calendars: [CalendarSource: [RCCalendar]],
         delegateCalendars: [CalendarSource: [RCCalendar]],
         events: [RCEvent],
         reminders: [RCReminder]) {
        self.calendars = calendars
        self.delegateCalendars = delegateCalendars
        self.events = events
        self.reminders = reminders
        self.calendarLookup = RCCalendarDataModel.createCalendarLookup(calendars: calendars,
                                                                     delegateCalendars: delegateCalendars)
    
        self.allItems = (self.events + self.reminders).sorted(by: { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        })
    }
    
    init() {
        self.calendars = [:]
        self.delegateCalendars = [:]
        self.events = []
        self.reminders = []
        self.calendarLookup = [:]
        self.allItems = []
    }
    
    private static func createCalendarLookup(calendars: [CalendarSource: [RCCalendar]],
                                     delegateCalendars: [CalendarSource: [RCCalendar]]) -> [String: RCCalendar] {
        
        var lookup: [String: RCCalendar] = [:]
        
        calendars.forEach { $1.forEach { lookup[$0.id] = $0 } }
        delegateCalendars.forEach { $1.forEach { lookup[$0.id] = $0 } }
        
        return lookup
    }

    public var description: String {
        return "\(type(of:self)): \(self.calendars)\ndelegate calendars: \(self.delegateCalendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    public func calendar(forIdentifier id: String) -> RCCalendar? {
        if let calendar = self.calendarLookup[id] {
            return calendar
        }
        return nil;
    }
    
    public func events(forCalendar calendar: RCCalendar) -> [RCEvent] {
        var outEvents: [RCEvent] = []
        for event in self.events {
            if event.calendar.id == calendar.id {
                outEvents.append(event)
            }
        }
        
        return outEvents
    }
    
    public func event(forIdentifier identifer: String) -> RCEvent? {
        for event in self.events {
            if event.id == identifer {
                return event
            }
        }
        
        return nil
    }

    public func reminder(forIdentifier identifer: String) -> RCReminder? {
        for reminder in self.reminders {
            if reminder.id == identifer {
                return reminder
            }
        }
        
        return nil
    }
    
    public func item(forIdentifier identifer: String) -> RCCalendarItem? {
        if let event = self.event(forIdentifier: identifer) {
            return event
        }
        if let reminder = self.reminder(forIdentifier: identifer) {
            return reminder
        }
        return nil
    }
}

