//
//  CalendarData.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

class CalendarData : ObservableObject, CustomStringConvertible {
    @Published var calendars: [String: [EventKitCalendar]] = [:]
    @Published var events: [EventKitEvent] = []
    @Published var reminders: [EventKitReminder] = []
    
    init(withCalendars calendars: [String: [EventKitCalendar]],
         events: [EventKitEvent],
         reminders: [EventKitReminder]) {
        self.calendars = calendars
        self.events = events
        self.reminders = reminders
    }
    
    convenience init() {
        self.init(withCalendars:[:], events:[], reminders:[])
    }
    
    var description: String {
        return "calenders: \(self.calendars)\nevents: \(self.events)\nreminders: \(self.reminders)"
    }
    
    func forceUpdate() {
        for (_, calendars) in self.calendars {
            for calendar in calendars {
                calendar.forceUpdate()
            }
        }
        for event in self.events {
            event.forceUpdate()
        }
        for reminder in self.reminders {
            reminder.forceUpdate()
        }

        self.objectWillChange.send()
    }
}
