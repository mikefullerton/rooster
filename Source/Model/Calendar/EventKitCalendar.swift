//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

//protocol Calendar {
//    var isSubscribed: Bool { get }
//    var title: String { get }
//    var id: String { get }
//    var sourceTitle: String { get }
//    var sourceIdentifier: String { get }
//}

struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable  {
    let EKCalendar: EKCalendar
    let title: String
    let id: String
    let sourceTitle: String
    let sourceIdentifier: String
    let events: [EventKitEvent]
    private(set) var isSubscribed: Bool
    
    init(withCalendar EKCalendar: EKCalendar,
         events: [EventKitEvent],
         subscribed: Bool) {
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
        self.title = EKCalendar.title
        self.id = EKCalendar.calendarIdentifier
        self.sourceTitle = EKCalendar.source.title
        self.sourceIdentifier = EKCalendar.source.sourceIdentifier
        self.events = events
    }
    
    var description: String {
        return "Calendar: \(self.sourceTitle): \(self.title)"
    }
    
    static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        return lhs.id == rhs.id
    }
    
    mutating func set(subscribed: Bool) {
        self.isSubscribed = subscribed
        AppController.instance.preferences.calendarIdentifers.set(isIncluded: self.isSubscribed, forKey: self.id)
    }
    
//    public func forceUpdate() {
//        self.objectWillChange.send()
//    }
}


