//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitReminder: Identifiable, Hashable, EventKitItem {
    
    typealias ItemType = EventKitReminder
    
    let EKReminder: EKReminder
    let calendar: EventKitCalendar
    
    let id: String
    let isSubscribed: Bool
    let alarm: EventKitAlarm
    let isCompleted: Bool
    let title: String
    let location: String?
    let notes: String?
    let url: URL?
    let noteURLS: [URL]?
    let dueDate: Date?
    let startDate: Date?

    init(withReminder EKReminder: EKReminder,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarm: EventKitAlarm) {
        self.id = EKReminder.uniqueID
        self.EKReminder = EKReminder
        self.isSubscribed = subscribed
        self.calendar = calendar
        self.alarm = alarm
        self.isCompleted = EKReminder.isCompleted
        self.title = EKReminder.title
        self.location = EKReminder.location
        self.notes = EKReminder.notes
        self.url = EKReminder.url
        self.dueDate = EKReminder.dueDateComponents?.date
        self.startDate = EKReminder.startDateComponents?.date
        
        if self.notes != nil {
            self.noteURLS = self.notes!.detectURLs()
        } else {
            self.noteURLS = nil
        }
    }

    var description: String {
        return "Reminder: \(self.title), Calendar: \(self.calendar)"
    }
    
    static func == (lhs: EventKitReminder, rhs: EventKitReminder) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.calendar.id == rhs.calendar.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.isCompleted == rhs.isCompleted &&
                lhs.dueDate == rhs.dueDate &&
                lhs.startDate == rhs.startDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func updateAlarm(_ alarm: EventKitAlarm) -> EventKitReminder {
        return EventKitReminder(withReminder: self.EKReminder,
                                calendar: self.calendar,
                                subscribed: self.isSubscribed,
                                alarm: alarm)
    }
    

}
