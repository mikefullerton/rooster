//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitReminder: Hashable, Identifiable {
    
    let EKReminder: EKReminder
    let isSubscribed: Bool
    
    init(withEvent EKReminder: EKReminder,
         subscribed: Bool) {
        self.EKReminder = EKReminder
        self.isSubscribed = subscribed
    }
    
    var id: String {
        return self.EKReminder.calendarItemIdentifier
    }
    
    var title: String {
        return self.EKReminder.title
    }
    
    var description: String {
        return "Reminder: \(self.title)"
    }
}
