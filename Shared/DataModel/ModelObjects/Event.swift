//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct Event: Identifiable, Hashable, CalendarItem {
    
    let calendar: Calendar
    
    let startDate: Date
    let endDate: Date
    let title: String
    let id: String
    let ekEventID: String
    let organizer: String?
    let location: String?
    let url: URL?
    let notes: String?
    let externalIdentifier: String
    
    // modifiable
    var isSubscribed: Bool
    var alarm: Alarm
    
    init(withIdentifier identifier: String,
         ekEventID: String,
         externalIdentifier: String,
         calendar: Calendar,
         subscribed: Bool,
         alarm: Alarm,
         startDate: Date,
         endDate: Date,
         title: String,
         location: String?,
         url: URL?,
         notes: String?,
         organizer: String?) {
        
        self.externalIdentifier = externalIdentifier
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
    }
    
    var description: String {
        return ("\(type(of:self)): title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), alarm: \(self.alarm)")
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
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
                lhs.organizer == rhs.organizer &&
                lhs.externalIdentifier == rhs.externalIdentifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    func isEqualTo(_ item: CalendarItem) -> Bool {
        if let comparingTo = item as? Event {
            return self == comparingTo
        }
        return false
    }
}

extension Event {
    func stopAlarmButtonClicked() {
        self.stopAlarm()
    }

    var timeLabelDisplayString: String {
        let startTime = self.startDate.shortTimeString
        let endTime = self.endDate.shortTimeString

        return "\(startTime) - \(endTime)"
    }
}


