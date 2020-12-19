//
//  EKReminder+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import EventKit

extension EKReminder {
    var uniqueID: String {
        return "\(self.calendar.uniqueID)+\(self.calendarItemExternalIdentifier ?? self.calendarItemIdentifier)"
    }
}

