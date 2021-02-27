//
//  EKCalendar+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import EventKit

extension EKCalendar {
    var uniqueID: String {
        return "\(self.source.sourceIdentifier)+\(self.calendarIdentifier)"
    }
}

