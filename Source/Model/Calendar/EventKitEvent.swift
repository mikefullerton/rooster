//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitEvent: Identifiable, Equatable, CustomStringConvertible, Hashable {
    let EKEvent: EKEvent
    let isSubscribed: Bool
    let calendarIdentifier: String
    let hasFired: Bool
    let isFiring: Bool
    let startDate: Date
    let endDate: Date
    let title: String
    let id: String
    

    init(withEvent EKEvent: EKEvent,
         calendarIdentifer: String,
         subscribed: Bool,
         isFiring: Bool,
         hasFired: Bool) {
        self.EKEvent = EKEvent
        self.id = EKEvent.eventIdentifier
        self.calendarIdentifier = calendarIdentifer
        self.title = EKEvent.title
        self.isSubscribed = subscribed
        self.hasFired = hasFired
        self.isFiring = isFiring
        self.startDate = EKEvent.startDate
        self.endDate = EKEvent.endDate
    }
    
    var isInProgress: Bool {
        let now = Date()
        return self.startDate.isBeforeDate(now) && self.endDate.isAfterDate(now)
    }
    
    static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return ("Event: title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), isFiring: \(self.isFiring), hasFired: \(self.hasFired)")
    }
    
    func isEqual(to anotherEvent: EventKitEvent) -> Bool {
        return  self.id == anotherEvent.id &&
                self.calendarIdentifier == anotherEvent.calendarIdentifier &&
                self.title == anotherEvent.title &&
                self.isSubscribed == anotherEvent.isSubscribed &&
                self.hasFired == anotherEvent.hasFired &&
                self.isFiring == anotherEvent.isFiring &&
                self.startDate == anotherEvent.startDate &&
                self.endDate == anotherEvent.endDate
    }

}


