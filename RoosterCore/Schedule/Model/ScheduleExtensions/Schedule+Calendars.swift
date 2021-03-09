//
//  Schedule+Calendars.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/3/21.
//

import Foundation

extension Schedule {
    public struct Calendars: Equatable, CustomStringConvertible, Loggable {
        public var calendarGroups: [CalendarGroup]
        public var delegateCalendarGroups: [CalendarGroup]

        public func calendar(forID id: String) -> CalendarScheduleItem? {
            self.calendar(forID: id, inGroups: self.calendarGroups) ??
            self.calendar(forID: id, inGroups: self.delegateCalendarGroups)
        }

        fileprivate func calendar(forID id: String, inGroups groups: [CalendarGroup]) -> CalendarScheduleItem? {
            for group in groups {
                if let index = group.calendars.firstIndex(where: { $0.eventKitCalendar.id == id }) {
                    return group.calendars[index]
                }
            }

            return nil
        }

        public var description: String {
            """
            \(type(of: self)):
            calendars: \(calendarGroups.description), \
            delegateCalendars: \(delegateCalendarGroups.description)
            """
        }

        public init(calendarGroups: [CalendarGroup],
                    delegateCalendarGroups: [CalendarGroup]) {
            self.calendarGroups = calendarGroups
            self.delegateCalendarGroups = delegateCalendarGroups
        }

        public init() {
            self.calendarGroups = []
            self.delegateCalendarGroups = []
        }

        public var enabledCalendars: [CalendarScheduleItem] {
            self.enabledCalendars(inGroups: self.calendarGroups)
        }

        public var enabledDelegateCalendars: [CalendarScheduleItem] {
            self.enabledCalendars(inGroups: self.delegateCalendarGroups)
        }

        public var enabledCalendarIDs: [String] {
            self.enabledCalendars.map { $0.eventKitCalendar.id }
        }

        public var enabledDelegateCalendarIDs: [String] {
            self.enabledDelegateCalendars.map { $0.eventKitCalendar.id }
        }

        public func isCalendarEnabled(calendarID: String) -> Bool {
            self.enabledCalendarIDs.contains(calendarID)
        }

        public func isDelegateCalendarEnabled(calendarID: String) -> Bool {
            self.enabledDelegateCalendarIDs.contains(calendarID)
        }

        public mutating func enableAllPersonalCalendars() {
            var groups: [CalendarGroup] = self.calendarGroups

            for outer in 0..<groups.count {
                for inner in 0..<groups[outer].calendars.count {
                    groups[outer].calendars[inner].isEnabled = true
                }
            }

            self.calendarGroups = groups
        }

        private func enabledCalendars(inGroups groups: [CalendarGroup]) -> [CalendarScheduleItem] {
            var subscribedCalendars: [CalendarScheduleItem] = []

            groups.forEach { group in
                group.calendars.forEach { calendar in
                    if calendar.isEnabled {
                        subscribedCalendars.append(calendar)
                    }
                }
            }

            return subscribedCalendars
        }
    }
}
