//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitEvent: Identifiable, Equatable, CustomStringConvertible {
    let EKEvent: EKEvent
    let isSubscribed: Bool
    let calendar: EventKitCalendar
    let hasFired: Bool
    let isFiring: Bool

    init(withEvent EKEvent: EKEvent,
         calendar: EventKitCalendar,
         subscribed: Bool,
         isFiring: Bool,
         hasFired: Bool) {
        self.EKEvent = EKEvent
        self.calendar = calendar
        self.isSubscribed = subscribed
        self.hasFired = hasFired
        self.isFiring = isFiring
    }
    
    var isInProgress: Bool {
        let now = Date()
        return self.startDate.isBeforeDate(now) && self.endDate.isAfterDate(now)
    }
    
    var title: String {
        return self.EKEvent.title
    }
    
    var startDate: Date {
        self.EKEvent.startDate
    }

    var endDate: Date {
        self.EKEvent.endDate
    }

    var id: String {
        return self.EKEvent.eventIdentifier
    }
    
    static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return ("Event: title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), isFiring: \(self.isFiring), hasFired: \(self.hasFired)")
    }
    
    func updatedEvent(isFiring: Bool, hasFired: Bool) -> EventKitEvent {
        return EventKitEvent(withEvent: self.EKEvent,
                             calendar: self.calendar,
                             subscribed: self.isSubscribed,
                             isFiring: isFiring,
                             hasFired: hasFired)
    }
}

extension EventKitEvent {
    func stopAlarm() {
        AppController.instance.stopAlarm(forEvent: self)
    }
}
