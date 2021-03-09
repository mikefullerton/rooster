//
//  EventKitRules.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/6/21.
//

import Foundation

public struct EventKitRules: Equatable, EKDataModelControllerRules {
    public let enabledCalendars: Set<String>
    public let enabledDelegateCalendars: Set<String>
    public let visibleDayCount: Int

    public init(enabledCalendars: Set<String>,
                enabledDelegateCalendars: Set<String>,
                visibleDayCount: Int) {
        self.enabledCalendars = enabledCalendars
        self.enabledDelegateCalendars = enabledDelegateCalendars
        self.visibleDayCount = visibleDayCount
    }

    public func isCalendarEnabled(calendarID: String) -> Bool {
        self.enabledCalendars.contains(calendarID)
    }

    public func isDelegateCalendarEnabled(calendarID: String) -> Bool {
        self.enabledDelegateCalendars.contains(calendarID)
    }

    public var dateRange: DateRange {
        DateRange(startDate: Date.midnightToday, dayCount: self.visibleDayCount)
    }
}
