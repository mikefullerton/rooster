//
//  EventKitEvent+EKEvent.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension EventKitEvent {
    init(withEvent EKEvent: EKEvent,
         calendar: EventKitCalendar,
         subscribed: Bool,
         alarm: EventKitAlarm) {

        self.init(withIdentifier: EKEvent.uniqueID,
                  ekEventID: EKEvent.eventIdentifier,
                  calendar: calendar,
                  subscribed: subscribed,
                  alarm: alarm,
                  startDate: EKEvent.startDate,
                  endDate: EKEvent.endDate,
                  title: EKEvent.title,
                  location: EKEvent.location,
                  url: EKEvent.url,
                  notes: EKEvent.notes,
                  noteURLS: nil,
                  organizer: EKEvent.organizer?.name)
    }

}
