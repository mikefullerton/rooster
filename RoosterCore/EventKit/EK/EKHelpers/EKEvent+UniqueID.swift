//
//  EKEvent+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import EventKit
import Foundation

extension EKEvent {
    var uniqueID: String {
        self.uniqueID(forStartDate: self.startDate)
    }
}
