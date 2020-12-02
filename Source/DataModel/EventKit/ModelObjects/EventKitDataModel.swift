//
//  EventKitDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

typealias CalendarSource = String
typealias CalendarID = String

struct EventKitDataModel : CustomStringConvertible {

    let calendars: [CalendarSource: [EventKitCalendar]]
    let delegateCalendars: [CalendarSource: [EventKitCalendar]]
    let events: [EventKitEvent]
    let reminders: [EventKitReminder]
    let calendarLookup: [CalendarID: EventKitCalendar]
        
    init(calendars: [CalendarSource: [EventKitCalendar]],
         delegateCalendars: [CalendarSource: [EventKitCalendar]],
         events: [EventKitEvent],
         reminders: [EventKitReminder],
         calendarLookup: [CalendarID: EventKitCalendar]) {
        self.calendars = calendars
        self.delegateCalendars = delegateCalendars
        self.events = events
        self.reminders = reminders
        self.calendarLookup = calendarLookup
    }
    
    init() {
        self.calendars = [:]
        self.delegateCalendars = [:]
        self.events = []
        self.reminders = []
        self.calendarLookup = [:]
    }
    
    var description: String {
        return "calenders: \(self.calendars)\ndelegate calendars: \(self.delegateCalendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    func findCalendar(forIdentifier id: String) -> EventKitCalendar? {
        if let calendar = self.calendarLookup[id] {
            return calendar
        }
        return nil;
    }
    
    func findEvents(forCalendar calendar: EventKitCalendar) -> [EventKitEvent] {
        var outEvents: [EventKitEvent] = []
        for event in self.events {
            if event.calendar.id == calendar.id {
                outEvents.append(event)
            }
        }
        
        return outEvents
    }
}

