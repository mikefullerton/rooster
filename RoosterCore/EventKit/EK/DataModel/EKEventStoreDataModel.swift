//
//  EKEventStoreDataModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

import EventKit
import Foundation

/// This represents the data we are interested in from a single EKEventStore. We later combine everything into a single EventKitDataModel
public struct EKEventStoreDataModel: Equatable, CustomStringConvertible {
    public let eventStore: EKEventStore?
    public let calendars: [EKCalendar]
    public let events: [EKEvent]
    public let reminders: [EKReminder]

    public init(eventStore: EKEventStore?,
                calendars: [EKCalendar],
                events: [EKEvent],
                reminders: [EKReminder]) {
        self.eventStore = eventStore
        self.calendars = calendars
        self.events = events
        self.reminders = reminders
    }

    public init() {
        self.init(eventStore: nil,
                  calendars: [],
                  events: [],
                  reminders: [])
    }

    public func calendar(forIdentifier identifier: String) -> EKCalendar? {
        self.calendars.first { $0.uniqueID == identifier }
    }

    public var description: String {
        """
        \(type(of: self)): \
        eventStore: \(self.eventStore?.shortDescription ?? "no event store"), \
        calendars: \(self.calendars.map { $0.shortDescription }.joined(separator: ", ")), \
        events: \(self.events.map { $0.shortDescription }.joined(separator: ", ")), \
        reminders: \(self.reminders.map { $0.shortDescription }.joined(separator: ", "))
        """
    }
}

extension EKEventStore {
    public var shortDescription: String {
        """
        \(type(of: self)): \
        eventStoreIdentifier: \(self.eventStoreIdentifier)
        """
    }
}

extension EKEvent {
    public var shortDescription: String {
        """
        \(type(of: self)): \
        title: \(self.title ?? "nil"), \
        event id: \(self.eventIdentifier ?? "nil"), \
        calendar item id: \(self.calendarItemIdentifier), \
        external identifier: \(self.calendarItemExternalIdentifier ?? "nil")
        """
    }
}

extension EKReminder {
    public var shortDescription: String {
        """
        \(type(of: self)): \
        title: \(self.title ?? "nil"), \
        calendar item id: \(self.calendarItemIdentifier), \
        external identifier: \(self.calendarItemExternalIdentifier ?? "nil")
        """
    }
}

extension EKCalendar {
    public var shortDescription: String {
        """
        \(Swift.type(of: self)): \
        id: \(self.calendarIdentifier), \
        source: \(self.source.title), \
        title: \(self.title),
        """
    }
}
