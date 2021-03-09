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
        return self.uniqueID(forStartDate: self.creationDate ?? Date())
    }
    
    public var dueDate: Date? {
        return self.dueDateComponents?.date ?? nil
    }
    
    public var startDate: Date? {
        return self.startDateComponents?.date ?? nil
    }
}

