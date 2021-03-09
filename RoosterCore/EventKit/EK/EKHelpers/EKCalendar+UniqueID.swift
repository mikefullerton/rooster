//
//  EKCalendar+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import EventKit
import Foundation

extension EKCalendar {
    var uniqueID: String {
        "\(self.source.sourceIdentifier)+\(self.calendarIdentifier)"
    }
}
