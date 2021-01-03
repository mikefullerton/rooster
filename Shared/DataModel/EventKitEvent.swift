//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct EventKitEvent: Identifiable, Hashable, EventKitItem {
    
    let calendar: EventKitCalendar
    
    let startDate: Date
    let endDate: Date
    let title: String
    let id: String
    let ekEventID: String
    let organizer: String?
    let location: String?
    let url: URL?
    let notes: String?
    let noteURLS: [URL]?

    // modifiable
    var isSubscribed: Bool
    var alarm: EventKitAlarm
    
    init(withIdentifier identifier: String,
         ekEventID: String,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarm: EventKitAlarm,
         startDate: Date,
         endDate: Date,
         title: String,
         location: String?,
         url: URL?,
         notes: String?,
         noteURLS: [URL]?,
         organizer: String?) {
        
        self.id = identifier
        self.ekEventID = ekEventID
        self.calendar = calendar
        self.title = title
        self.isSubscribed = subscribed
        self.alarm = alarm
        self.startDate = startDate
        self.endDate = endDate
        self.organizer = organizer
        self.location = location
        self.url = url
        self.notes = notes
        
        if notes != nil && noteURLS == nil {
            self.noteURLS = notes!.detectURLs()
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
    
    func isEqualTo(_ item: EventKitItem) -> Bool {
        if let comparingTo = item as? EventKitEvent {
            return self == comparingTo
        }
        return false
    }
}




