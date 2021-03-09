//
//  EventKitDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/18/20.
//

import Foundation

public typealias CalendarSource = String
public typealias CalendarID = String

public struct EventKitDataModel: CustomStringConvertible, Equatable, Loggable, ShortCustomStringConvertable {
    public let calendars: [EventKitCalendar]
    public let delegateCalendars: [EventKitCalendar]
    public let events: [EventKitEvent]
    public let reminders: [EventKitReminder]

    init(calendars: [EventKitCalendar],
         delegateCalendars: [EventKitCalendar],
         events: [EventKitEvent],
         reminders: [EventKitReminder]) {
        self.calendars = calendars
        self.delegateCalendars = delegateCalendars
        self.events = events
        self.reminders = reminders
    }

    init() {
        self.calendars = []
        self.delegateCalendars = []
        self.events = []
        self.reminders = []
    }

    public var description: String {
        """
        \(type(of: self)): \
        calendars: \(self.calendars.joinedDescription), \
        delegate calendars: \(self.delegateCalendars.joinedDescription)), \
        events: \(self.events.joinedDescription), \
        reminders: \(self.reminders.joinedDescription)
        """
    }

    public var shortDescription: String {
        """
        \(type(of: self)): \
        calendars count: \(self.calendars.count), \
        delegate calendars count: \(self.delegateCalendars.count)), \
        events count: \(self.events.count), \
        reminders count: \(self.reminders.count)
        """
    }

    public static func == (lhs: EventKitDataModel, rhs: EventKitDataModel) -> Bool {
        lhs.calendars == rhs.calendars &&
                lhs.delegateCalendars == rhs.delegateCalendars &&
                lhs.events == rhs.events &&
                lhs.reminders == rhs.reminders
    }
}
