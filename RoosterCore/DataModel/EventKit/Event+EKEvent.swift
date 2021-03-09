//
//  RCEvent+EKEvent.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension RCEvent {
    init(withEvent EKEvent: EKEvent,
         calendar: RCCalendar,
         subscribed: Bool,
         alarm: RCAlarm) {

        self.init(withIdentifier: EKEvent.uniqueID,
                  ekEvent: EKEvent,
                  calendar: calendar,
                  subscribed: subscribed,
                  alarm: alarm)
    }

}
