//
//  RCEvent.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

public struct RCEvent: Identifiable, Hashable, RCCalendarItem {
    
    public let calendar: RCCalendar
    
    public let startDate: Date
    public let endDate: Date
    public let title: String
    public let id: String
    public let ekEventID: String
    public let organizer: String?
    public let location: String?
    public let url: URL?
    public let notes: String?
    public let externalIdentifier: String
    
    // modifiable
    public var isSubscribed: Bool
    public var alarm: RCAlarm
    
    public init(withIdentifier identifier: String,
         ekEventID: String,
         externalIdentifier: String,
         calendar: RCCalendar,
         subscribed: Bool,
         alarm: RCAlarm,
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
    
    public var description: String {
        return ("\(type(of:self)): title: \(self.title), startTime: \(self.startDate), endTime: \(self.endDate), alarm: \(self.alarm)")
    }
    
    public static func == (lhs: RCEvent, rhs: RCEvent) -> Bool {
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public func isEqualTo(_ item: RCCalendarItem) -> Bool {
        if let comparingTo = item as? RCEvent {
            return self == comparingTo
        }
        return false
    }
}

extension RCEvent {
    public func stopAlarmButtonClicked() {
        self.setAlarmMuted(!self.alarm.isMuted)
    }

    public var timeLabelDisplayString: String {
        let startTime = self.startDate.shortTimeString
        let endTime = self.endDate.shortTimeString

        return "\(startTime) - \(endTime)"
    }
}


