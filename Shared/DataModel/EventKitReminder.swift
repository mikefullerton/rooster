//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct EventKitReminder: Identifiable, Hashable, EventKitItem {
    
    typealias ItemType = EventKitReminder
    
    let calendar: EventKitCalendar
    
    let id: String
    let ekReminderID: String
    let isSubscribed: Bool
    let alarm: EventKitAlarm
    let isCompleted: Bool
    let title: String
    let location: String?
    let notes: String?
    let url: URL?
    let noteURLS: [URL]?
    let dueDate: Date
    let startDate: Date
    
    init(withIdentifier identifier: String,
         ekReminderID: String,
         calendar: EventKitCalendar,
         subscribed: Bool,
         completed: Bool,
         alarm: EventKitAlarm,
         startDate: Date,
         dueDate: Date,
         title: String,
         location: String?,
         url: URL?,
         notes: String?,
         noteURLS: [URL]?) {

        self.calendar = calendar
        self.id = identifier
        self.ekReminderID = ekReminderID
        self.isSubscribed = subscribed
        self.alarm = alarm
        self.isCompleted = completed
        self.title = title
        self.startDate = startDate
        self.dueDate = dueDate
        self.location = location
        self.url = url
        self.notes = notes
        
        if notes != nil && noteURLS == nil {
            self.noteURLS = notes!.detectURLs()
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
    
    func itemWithUpdatedAlarm(_ alarm: EventKitAlarm) -> EventKitReminder {
        
        return EventKitReminder(withIdentifier: self.id,
                                ekReminderID: self.ekReminderID,
                                calendar: self.calendar,
                                subscribed: self.isSubscribed,
                                completed: self.isCompleted,
                                alarm: alarm,
                                startDate: self.startDate,
                                dueDate: self.dueDate,
                                title: self.title,
                                location: self.location,
                                url: self.url,
                                notes: self.notes,
                                noteURLS: self.noteURLS)
    }
    

}
