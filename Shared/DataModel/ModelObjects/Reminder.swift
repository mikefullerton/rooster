//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct Reminder: Identifiable, Hashable, CalendarItem {
    
    let calendar: Calendar
    let id: String
    let ekReminderID: String
    let isCompleted: Bool
    let title: String
    let location: String?
    let notes: String?
    let url: URL?
    let dueDate: Date
    let startDate: Date
    let externalIdentifier: String
    
    // modifiable
    var isSubscribed: Bool
    var alarm: Alarm

    init(withIdentifier identifier: String,
         ekReminderID: String,
         externalIdentifier: String,
         calendar: Calendar,
         subscribed: Bool,
         completed: Bool,
         alarm: Alarm,
         startDate: Date,
         dueDate: Date,
         title: String,
         location: String?,
         url: URL?,
         notes: String?) {

        self.externalIdentifier = externalIdentifier
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
    }

    var description: String {
        return "Reminder: \(self.title), Calendar: \(self.calendar)"
    }
    
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
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
                lhs.startDate == rhs.startDate  &&
                lhs.externalIdentifier == rhs.externalIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func isEqualTo(_ item: CalendarItem) -> Bool {
        if let comparingTo = item as? Reminder {
            return self == comparingTo
        }
        return false
    }
}

extension Reminder {
    func stopAlarmButtonClicked() {
        self.snoozeAlarm()
    }

    var timeLabelDisplayString: String {
        return "Reminder Due at: \(self.alarm.startDate))"
    }
}
