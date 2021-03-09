//
//  CalendarScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public struct ScheduleCalendar: Calendar, Enableable, Equatable, Identifiable {
    public typealias ID = String

    public let id: String

    internal var storageRecord: ScheduleCalendarStorageRecord

    fileprivate var eventKitCalendar: EventKitCalendar

    public var title: String

    public var cgColor: CGColor? {
        didSet { self.eventKitCalendar.cgColor = cgColor }
    }

    public var color: NSColor? {
        didSet { self.eventKitCalendar.color = color }
    }

    public let source: CalendarSource

    public let allowsEvents: Bool

    public let allowsReminders: Bool

    public let isReadOnly: Bool

    public var calendar: Calendar {
        self.eventKitCalendar
    }

    public var isEnabled: Bool {
        didSet { self.storageRecord.isEnabled = isEnabled }
    }

    public var description: String {
        """
        \(type(of: self)) \
        calendar: \(self.eventKitCalendar.description) \
        isEnabled == \(self.isEnabled)
        """
    }

    public static func == (lhs: ScheduleCalendar, rhs: ScheduleCalendar) -> Bool {
        lhs.eventKitCalendar.isEqual(to: rhs.eventKitCalendar) &&
        lhs.id == rhs.id &&
        lhs.storageRecord == rhs.storageRecord &&
        lhs.isEnabled == rhs.isEnabled
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let otherCalendar = scheduleItem as? ScheduleCalendar else { return false }
        return otherCalendar == self
    }
}

extension ScheduleCalendar {
    public init(calendar: EventKitCalendar,
                storageRecord: ScheduleCalendarStorageRecord) {
        self.id = calendar.id
        self.eventKitCalendar = calendar
        self.storageRecord = storageRecord

        self.title = calendar.title
        self.cgColor = calendar.cgColor
        self.color = calendar.color
        self.source = calendar.source
        self.allowsEvents = calendar.allowsEvents
        self.allowsReminders = calendar.allowsReminders
        self.isReadOnly = calendar.isReadOnly
        self.isEnabled = storageRecord.isEnabled
    }
}
