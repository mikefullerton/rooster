//
//  EventKitCalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol EventKitCalendarItem: CalendarItem, EventKitWriteable {
    var externalIdentifier: String { get }
}
