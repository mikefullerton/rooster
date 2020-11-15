//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct Reminder {
    
    let EKReminder: EKReminder
    let identifier: String
    let isSubscribed: Bool
    
    init(withEvent EKReminder: EKReminder,
         subscribed: Bool) {
        self.identifier = EKReminder.calendarItemIdentifier
        self.EKReminder = EKReminder
        self.isSubscribed = subscribed
    }
}
