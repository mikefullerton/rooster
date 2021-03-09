//
//  Calendar+EKCalender.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension RCCalendar {
    init(withCalendar ekCalendar: EKCalendar,
         subscribed: Bool) {
        
        self.init(withIdentifier: ekCalendar.uniqueID,
                  ekCalendar: ekCalendar,
                  isSubscribed: subscribed)
    }
}
