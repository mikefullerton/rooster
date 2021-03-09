//
//  EKDataModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit

/// This represents the data we are interested in from a single EKEventStore. We later combine everything into a single RCCalendarDataModel
struct EKDataModel {
    let eventStore: EKEventStore?
    
    let calendars:[EKCalendar]
    let events:[EKEvent]
    let reminders:[EKReminder]
    
    func calendar(forIdentifier identifier: String) -> EKCalendar? {
        return self.calendars.first(where: { $0.uniqueID == identifier })
    }
}
