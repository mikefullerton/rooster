//
//  RCReminder+EKReminder.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension RCReminder {
    
    init(withReminder EKReminder: EKReminder,
         calendar: RCCalendar,
         subscribed: Bool,
         alarm: RCAlarm) {
        
        self.init(withIdentifier: EKReminder.uniqueID,
                  ekReminder: EKReminder,
                  calendar: calendar,
                  subscribed: subscribed,
                  alarm: alarm)

    }
    
}
