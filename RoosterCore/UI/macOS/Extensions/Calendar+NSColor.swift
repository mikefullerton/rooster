//
//  Calendar+NSColor.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation

import Cocoa

extension RCCalendar {
    public var color: NSColor? {
        get {
            return self.cgColor != nil ? NSColor(cgColor: self.cgColor!) : nil
        }
        set(color) {
            self.cgColor = color?.cgColor
        }
    }
}
