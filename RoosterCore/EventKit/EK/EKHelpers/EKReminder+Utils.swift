//
//  EKReminder+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import EventKit
import Foundation

extension EKReminder {
    var uniqueID: String {
        self.uniqueID(forStartDate: self.creationDate ?? Date())
    }

    public var dueDate: Date? {
        self.dueDateComponents?.date
    }

    public var startDate: Date? {
        self.startDateComponents?.date
    }
}
