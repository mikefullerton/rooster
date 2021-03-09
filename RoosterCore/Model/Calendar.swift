//
//  Calendar.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol Calendar: StringIdentifiable, AbstractEquatable, CustomStringConvertible, Loggable {
    var title: String { get }
    var cgColor: CGColor? { get }
    var color: NSColor? { get }

    var source: CalendarSource { get }

    var allowsEvents: Bool { get }
    var allowsReminders: Bool { get }
    var isReadOnly: Bool { get }
}
