//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct Calendar {
    
    let EKCalendar: EKCalendar
    let identifier: String
    let isSubscribed: Bool
    
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        self.identifier = EKCalendar.calendarIdentifier
        self.EKCalendar = EKCalendar
        self.isSubscribed = subscribed
    }
}
