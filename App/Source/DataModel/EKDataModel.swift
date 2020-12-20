//
//  EKDataModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit
import OSLog

struct EKDataModel {
    let calendars:[EKCalendar]
    let events:[EKEvent]
    let reminders:[EKReminder]
    
    func calendar(forIdentifier identifier: String) -> EKCalendar? {
        return self.calendars.first(where: { $0.uniqueID == identifier })
    }
}
