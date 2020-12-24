//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable  {
    let EKCalendar: EKCalendar
    let title: String
    let id: String
    let sourceTitle: String
    let sourceIdentifier: String
    let isSubscribed: Bool
    
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
        self.title = EKCalendar.title
        self.id = EKCalendar.uniqueID
        self.sourceTitle = EKCalendar.source.title
        self.sourceIdentifier = EKCalendar.source.sourceIdentifier
    }
    
    var description: String {
        return "Calendar: \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }
    
    static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.sourceTitle == rhs.sourceTitle &&
                lhs.sourceIdentifier == rhs.sourceIdentifier
    }
 
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    func calendarWithSubscriptionChange(isSubscribed: Bool) -> EventKitCalendar {
        return EventKitCalendar(withCalendar: self.EKCalendar, subscribed: isSubscribed)
    }
}


