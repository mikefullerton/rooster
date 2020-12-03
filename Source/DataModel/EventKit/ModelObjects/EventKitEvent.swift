//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitEvent: Identifiable, Equatable, CustomStringConvertible, Hashable {

    enum AlarmState: String{
        case neverFired = "neverFired"
        case firing = "firing"
        case finished = "finishe"
    }

    let EKEvent: EKEvent
    
    let calendar: EventKitCalendar
    
    let isSubscribed: Bool
    let alarmState: AlarmState
    
    let startDate: Date
    let endDate: Date
    let title: String
    let id: String
    let organizer: String?
    let location: String?
    let eventURL: URL?
    let notes: String?
    let noteURLS: [URL]?
    
    init(withEvent EKEvent: EKEvent,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarmState: AlarmState) {
        self.EKEvent = EKEvent
        self.id = EKEvent.eventIdentifier
        self.calendar = calendar
        self.title = EKEvent.title
        self.isSubscribed = subscribed
        self.alarmState = alarmState
        self.startDate = EKEvent.startDate
        self.endDate = EKEvent.endDate
        self.organizer = EKEvent.organizer?.name
        self.location = EKEvent.location
        self.eventURL = EKEvent.url
        self.notes = EKEvent.notes
        if self.notes != nil {
            self.noteURLS = self.notes!.detectURLs()
        } else {
            self.noteURLS = nil
        }
    }
    
    static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    var description: String {
        return ("Event: title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), alarmState: \(self.alarmState)")
    }
    
    func isEqual(to anotherEvent: EventKitEvent) -> Bool {
        return  self.id == anotherEvent.id &&
                self.calendar.id == anotherEvent.calendar.id &&
                self.title == anotherEvent.title &&
                self.isSubscribed == anotherEvent.isSubscribed &&
                self.alarmState == anotherEvent.alarmState &&
                self.startDate == anotherEvent.startDate &&
                self.endDate == anotherEvent.endDate &&
                self.location == anotherEvent.location &&
                self.eventURL == anotherEvent.eventURL &&
                self.notes == anotherEvent.notes &&
                self.organizer == anotherEvent.organizer
    }

    var isHappeningNow: Bool {
        let now = Date()
        return self.startDate.isBeforeDate(now) && self.endDate.isAfterDate(now)
    }
    
    var alarmShouldStop: Bool {
        return !self.isHappeningNow && self.alarmState != .finished
    }
    
    var alarmShouldFire: Bool {
        return self.isHappeningNow && self.alarmState == .neverFired
    }
    
    var alarmIsFiring: Bool {
        return self.alarmState == .firing
    }
    
    func eventWithUpdatedAlarmState(_ alarmState: AlarmState) -> EventKitEvent {
        return EventKitEvent(withEvent: self.EKEvent,
                             calendar: self.calendar,
                             subscribed: self.isSubscribed,
                             alarmState: alarmState)
    }

    
    
}




