//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit
import UIKit

struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable  {
    let EKCalendar: EKCalendar
    let title: String
    let id: String
    let sourceTitle: String
    let sourceIdentifier: String
    let isSubscribed: Bool
    let color: UIColor?
    
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
        self.title = EKCalendar.title
        self.id = EKCalendar.calendarIdentifier
        self.sourceTitle = EKCalendar.source.title
        self.sourceIdentifier = EKCalendar.source.sourceIdentifier
        
        self.color = UIColor(cgColor: EKCalendar.cgColor)
    }
    
    var description: String {
        return "Calendar: \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }
    
    static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    func isEqual(to anotherCalendar: EventKitCalendar) -> Bool {
        return  self.id == anotherCalendar.id &&
                self.title == anotherCalendar.title &&
                self.isSubscribed == anotherCalendar.isSubscribed &&
                self.sourceTitle == anotherCalendar.sourceTitle &&
                self.sourceIdentifier == anotherCalendar.sourceIdentifier
    }
    
}


