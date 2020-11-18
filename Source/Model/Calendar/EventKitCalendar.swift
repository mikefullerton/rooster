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

class EventKitCalendar: Identifiable, ObservableObject, CustomStringConvertible, Equatable  {
    @Published private(set) var EKCalendar: EKCalendar
    @Published private(set) var title: String
    @Published private(set) var id: String
    @Published private(set) var sourceTitle: String
    @Published private(set) var sourceIdentifier: String
    
    @Published var isSubscribed: Bool {
        didSet {
            AppController.instance.preferences.calendarIdentifers.set(isIncluded: self.isSubscribed, forKey: self.id)
        }
    }
    
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
        self.title = EKCalendar.title
        self.id = EKCalendar.calendarIdentifier
        self.sourceTitle = EKCalendar.source.title
        self.sourceIdentifier = EKCalendar.source.sourceIdentifier
    }
    
    var description: String {
        return "Calendar: \(self.sourceTitle): \(self.title)"
    }
    
    static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func forceUpdate() {
        self.objectWillChange.send()
    }
}


