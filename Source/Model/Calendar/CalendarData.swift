//
//  CalendarData.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

class CalendarData : ObservableObject, CustomStringConvertible {
    // key: source
    @Published var calendars: [String: [EventKitCalendar]] = [:]
    
    // key: source
    @Published var delegateCalendars: [String: [EventKitCalendar]] = [:]
    
    @Published var events: [EventKitEvent] = []
    
    @Published var reminders: [EventKitReminder] = []
    
    // key: calendarID
    @Published var calenderLookup: [String: EventKitCalendar]
    
    init(withCalendars calendars: [String: [EventKitCalendar]],
         delegateCalendars: [String: [EventKitCalendar]],
         events: [EventKitEvent],
         reminders: [EventKitReminder],
         calendarLookup: [String: EventKitCalendar]) {
        self.delegateCalendars = delegateCalendars
        self.calendars = calendars
        self.events = events
        self.reminders = reminders
        self.calenderLookup = calendarLookup
    }
    
    convenience init() {
        self.init(withCalendars:[:], delegateCalendars: [:], events:[], reminders:[], calendarLookup: [:])
    }
    
    var description: String {
        return "calenders: \(self.calendars)\ndelegate calendars: \(self.delegateCalendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    func forceUpdate() {
        self.objectWillChange.send()
    }
}

