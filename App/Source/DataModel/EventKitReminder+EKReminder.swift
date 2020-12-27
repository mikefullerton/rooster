//
//  EventKitReminder+EKReminder.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension EventKitReminder {
    
    init(withReminder EKReminder: EKReminder,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarm: EventKitAlarm) {
        
        self.init(withIdentifier: EKReminder.uniqueID,
                  ekReminderID: EKReminder.calendarItemIdentifier,
                  calendar: calendar,
                  subscribed: subscribed,
                  completed: EKReminder.isCompleted,
                  alarm: alarm,
                  startDate: EKReminder.startDateComponents?.date ?? Date.distantFuture,
                  dueDate: EKReminder.dueDateComponents?.date ?? Date.distantFuture,
                  title: EKReminder.title,
                  location: EKReminder.location,
                  url: EKReminder.url,
                  notes: EKReminder.notes,
                  noteURLS: nil)

    }
    
}
