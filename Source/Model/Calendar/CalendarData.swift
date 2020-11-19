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
        self.objectWillChange.send()
    }
}
//
