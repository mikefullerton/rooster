//
//  Reminder+EKReminder.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension Reminder {
    
    init(withReminder EKReminder: EKReminder,
         calendar: Calendar,
         subscribed: Bool,
         alarm: Alarm) {
        
        self.init(withIdentifier: EKReminder.uniqueID,
                  ekReminderID: EKReminder.calendarItemIdentifier,
                  externalIdentifier: EKReminder.calendarItemExternalIdentifier,
                  calendar: calendar,
                  subscribed: subscribed,
                  completed: EKReminder.isCompleted,
                  alarm: alarm,
                  startDate: EKReminder.startDateComponents?.date ?? Date.distantFuture,
                  dueDate: EKReminder.dueDateComponents?.date ?? Date.distantFuture,
                  title: EKReminder.title,
                  location: EKReminder.location,
                  url: EKReminder.url,
                  notes: EKReminder.notes)

    }
    
}
