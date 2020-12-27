//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable  {

    let title: String
    let id: String
    let ekCalendarID: String
    let sourceTitle: String
    let sourceIdentifier: String
    let isSubscribed: Bool
    let cgColor: CGColor?
    
    init(withIdentifier identifier: String,
         ekCalendarID: String,
         title: String,
         sourceTitle: String,
         sourceIdentifier: String,
         isSubscribed: Bool,
         color: CGColor?) {
        
        self.id = identifier
        self.ekCalendarID = ekCalendarID
        self.title = title
        self.sourceTitle = sourceTitle
        self.sourceIdentifier = sourceIdentifier
        self.isSubscribed = isSubscribed
        self.cgColor = color
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
        return EventKitCalendar(withIdentifier: self.id,
                                ekCalendarID: self.ekCalendarID,
                                title: self.title,
                                sourceTitle: self.sourceTitle,
                                sourceIdentifier: self.sourceIdentifier,
                                isSubscribed: isSubscribed,
                                color: self.cgColor)
    }
}


