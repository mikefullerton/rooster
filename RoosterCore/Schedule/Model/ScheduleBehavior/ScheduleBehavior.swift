//
//  ScheduleBehavior.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/10/21.
//

import Foundation

public struct ScheduleBehavior: Equatable, CustomStringConvertible {
    public var calendarScheduleBehavior: CalendarScheduleBehavior
    public var eventScheduleBehavior: EventScheduleBehavior
    public var reminderScheduleBehavior: ReminderScheduleBehavior

    public init() {
        self.init(calendarScheduleBehavior: CalendarScheduleBehavior(),
                  eventScheduleBehavior: EventScheduleBehavior(),
                  reminderScheduleBehavior: ReminderScheduleBehavior())
    }

    public init(calendarScheduleBehavior: CalendarScheduleBehavior,
                eventScheduleBehavior: EventScheduleBehavior,
                reminderScheduleBehavior: ReminderScheduleBehavior) {
        self.calendarScheduleBehavior = calendarScheduleBehavior
        self.eventScheduleBehavior = eventScheduleBehavior
        self.reminderScheduleBehavior = reminderScheduleBehavior
    }

    public var description: String {
        """
        \(type(of: self)): \
        calendars: \(calendarScheduleBehavior.description), \
        events: \(eventScheduleBehavior.description), \
        reminders: \(reminderScheduleBehavior.description)
        """
    }
}

extension ScheduleBehavior: Codable {
}
