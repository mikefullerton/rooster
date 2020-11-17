//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

protocol Calendar {
    var isSubscribed: Bool { get }
    var title: String { get }
    var id: String { get }
    var sourceTitle: String { get }
    var sourceIdentifier: String { get }
}

struct EventKitCalendar: Calendar, Identifiable  {
    let EKCalendar: EKCalendar
    var isSubscribed: Bool
    
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
    }
    
    var id: String {
        return self.EKCalendar.calendarIdentifier
    }
    
    var title: String {
        return self.EKCalendar.title
    }
    
    var sourceTitle: String {
        return self.EKCalendar.source.title
    }

    var sourceIdentifier: String {
        return self.EKCalendar.source.sourceIdentifier
    }

}


