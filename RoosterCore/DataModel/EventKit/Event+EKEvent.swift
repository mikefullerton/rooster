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
                  ekEventID: EKEvent.eventIdentifier,
                  externalIdentifier: EKEvent.calendarItemExternalIdentifier,
                  calendar: calendar,
                  subscribed: subscribed,
                  alarm: alarm,
                  startDate: EKEvent.startDate,
                  endDate: EKEvent.endDate,
                  title: EKEvent.title,
                  location: EKEvent.location,
                  url: EKEvent.url,
                  notes: EKEvent.notes,
                  organizer: EKEvent.organizer?.name)
    }

}
