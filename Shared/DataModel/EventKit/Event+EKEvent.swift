//
//  Event+EKEvent.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import EventKit

extension Event {
    init(withEvent EKEvent: EKEvent,
         calendar: Calendar,
         subscribed: Bool,
         alarm: Alarm) {

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
                  organizer: EKEvent.organizer?.name)
    }

}
