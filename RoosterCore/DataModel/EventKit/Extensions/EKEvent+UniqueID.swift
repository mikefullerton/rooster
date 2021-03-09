//
//  EKEvent+UniqueID.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import EventKit

extension EKEvent {
    var uniqueID: String {
        return self.uniqueID(forStartDate: self.startDate)
    }
}
