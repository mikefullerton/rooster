//
//  Calendar+EKCalender.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension Calendar {
    init(withCalendar EKCalendar: EKCalendar,
         subscribed: Bool) {
        
        self.init(withIdentifier: EKCalendar.uniqueID,
                  ekCalendarID: EKCalendar.calendarIdentifier,
                  title: EKCalendar.title,
                  sourceTitle: EKCalendar.source.title,
                  sourceIdentifier: EKCalendar.source.sourceIdentifier,
                  isSubscribed: subscribed,
                  color:EKCalendar.cgColor)
    }
}
