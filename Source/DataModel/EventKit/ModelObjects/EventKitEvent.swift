//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitEvent: Identifiable, Hashable, EventKitItem {
    typealias ItemType = EventKitEvent
    
    let EKEvent: EKEvent
    let calendar: EventKitCalendar
    
    let isSubscribed: Bool
    let alarm: EventKitAlarm
    
    let startDate: Date
    let endDate: Date
    let title: String
    let id: String
    let organizer: String?
    let location: String?
    let url: URL?
    let notes: String?
    let noteURLS: [URL]?
    
    init(withEvent EKEvent: EKEvent,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarm: EventKitAlarm) {
        self.EKEvent = EKEvent
        self.id = EKEvent.uniqueID
        self.calendar = calendar
        self.title = EKEvent.title
        self.isSubscribed = subscribed
        self.alarm = alarm
        self.startDate = EKEvent.startDate
        self.endDate = EKEvent.endDate
        self.organizer = EKEvent.organizer?.name
        self.location = EKEvent.location
        self.url = EKEvent.url
        self.notes = EKEvent.notes
        if self.notes != nil {
            self.noteURLS = self.notes!.detectURLs()
        } else {
            self.noteURLS = nil
        }
    }
    
    var description: String {
        return ("Event: title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), alarm: \(self.alarm)")
    }
    
    static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.calendar.id == rhs.calendar.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.startDate == rhs.startDate &&
                lhs.endDate == rhs.endDate &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.organizer == rhs.organizer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func updateAlarm(_ alarm: EventKitAlarm) -> EventKitEvent {
        return EventKitEvent(withEvent: self.EKEvent,
                             calendar: self.calendar,
                             subscribed: self.isSubscribed,
                             alarm: alarm)
    }
}




