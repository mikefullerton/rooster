//
//  EventKitCalendarSource.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import EventKit
import Foundation

public struct EventKitCalendarSource: Identifiable, CustomStringConvertible, Equatable, CalendarSource {
    public typealias ID = String

    public let id: String
    public let title: String

    private let eventKitCalendarSource: EKSource

    public init(eventKitCalendarSource source: EKSource) {
        self.eventKitCalendarSource = source
        self.title = source.title
        self.id = source.sourceIdentifier
    }

    public var description: String {
        """
        \(type(of: self)): \
        title: \(self.title)
        """
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let otherCalendar = scheduleItem as? EventKitCalendarSource else { return false }
        return otherCalendar == self
    }

    public static func == (lhs: EventKitCalendarSource, rhs: EventKitCalendarSource) -> Bool {
        lhs.id == rhs.id
    }
}
