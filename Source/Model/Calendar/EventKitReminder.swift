//
//  Reminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

class EventKitReminder: Identifiable, ObservableObject, Equatable {
    let EKReminder: EKReminder
    @Published var isSubscribed: Bool
    
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
    
    public func forceUpdate() {
        self.objectWillChange.send()
    }

    static func == (lhs: EventKitReminder, rhs: EventKitReminder) -> Bool {
        return lhs === rhs
    }
}
