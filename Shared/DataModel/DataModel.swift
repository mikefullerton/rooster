//
//  DataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

typealias CalendarSource = String
typealias CalendarID = String

struct DataModel : CustomStringConvertible {

    let calendars: [CalendarSource: [Calendar]]
    let delegateCalendars: [CalendarSource: [Calendar]]
    let events: [Event]
    let reminders: [Reminder]
    let calendarLookup: [CalendarID: Calendar]
    
    let allItems: [CalendarItem]
        
    init(calendars: [CalendarSource: [Calendar]],
         delegateCalendars: [CalendarSource: [Calendar]],
         events: [Event],
         reminders: [Reminder]) {
        self.calendars = calendars
        self.delegateCalendars = delegateCalendars
        self.events = events
        self.reminders = reminders
        self.calendarLookup = DataModel.createCalendarLookup(calendars: calendars,
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
    
    private static func createCalendarLookup(calendars: [CalendarSource: [Calendar]],
                                     delegateCalendars: [CalendarSource: [Calendar]]) -> [String: Calendar] {
        
        var lookup: [String: Calendar] = [:]
        
        calendars.forEach { $1.forEach { lookup[$0.id] = $0 } }
        delegateCalendars.forEach { $1.forEach { lookup[$0.id] = $0 } }
        
        return lookup
    }

    var description: String {
        return "\(type(of:self)): \(self.calendars)\ndelegate calendars: \(self.delegateCalendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    func calendar(forIdentifier id: String) -> Calendar? {
        if let calendar = self.calendarLookup[id] {
            return calendar
        }
        return nil;
    }
    
    func events(forCalendar calendar: Calendar) -> [Event] {
        var outEvents: [Event] = []
        for event in self.events {
            if event.calendar.id == calendar.id {
                outEvents.append(event)
            }
        }
        
        return outEvents
    }
    
    func event(forIdentifier identifer: String) -> Event? {
        for event in self.events {
            if event.id == identifer {
                return event
            }
        }
        
        return nil
    }

    func reminder(forIdentifier identifer: String) -> Reminder? {
        for reminder in self.reminders {
            if reminder.id == identifer {
                return reminder
            }
        }
        
        return nil
    }
    
    func item(forIdentifier identifer: String) -> CalendarItem? {
        if let event = self.event(forIdentifier: identifer) {
            return event
        }
        if let reminder = self.reminder(forIdentifier: identifer) {
            return reminder
        }
        return nil
    }
}

