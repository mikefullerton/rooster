//
//  CalendarGroup.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/28/21.
//

import Foundation

public struct CalendarGroup: Equatable, CustomStringConvertible {
    public var source: String
    public var calendars: [ScheduleCalendar]

    public init(withCalendarSource source: String,
                calendars: [ScheduleCalendar]) {
        self.source = source
        self.calendars = calendars
    }

    public var description: String {
        """
        \(type(of: self)) \
        source: \(self.source) \
        calendars: \(self.calendars.map { $0.description }.joined(separator: ", "))
        """
    }
}
