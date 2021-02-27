//
//  Calendar+NSColor.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import RoosterCore
import Cocoa

extension RCCalendar {
    var color: NSColor? {
        return self.cgColor != nil ? NSColor(cgColor: self.cgColor!) : nil
    }
}
