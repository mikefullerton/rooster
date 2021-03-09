//
//  DataModelStorageRecord.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/17/21.
//

import Foundation

public struct ScheduleStorageRecord: Equatable, CustomStringConvertible {
    public var calendars: [String: ScheduleCalendarStorageRecord]
    public var delegateCalendars: [String: ScheduleCalendarStorageRecord]
    public var events: [String: EventScheduleItemStorageRecord]
    public var reminders: [String: ReminderScheduleItemStorageRecord]

    public init(withSchedule schedule: Schedule) {
        var events: [String: EventScheduleItemStorageRecord] = [:]
        var reminders: [String: ReminderScheduleItemStorageRecord] = [:]

        for item in schedule.items {
            if let event = item as? EventScheduleItem {
                if let existing = events[event.eventKitItemID] {
                    if event.eventStorageRecord.modificationDate.isAfterDate(existing.modificationDate) {
                        events[event.eventKitItemID] = event.eventStorageRecord
                    }
                } else {
                    events[event.eventKitItemID] = event.eventStorageRecord
                }
            }

            if let reminder = item as? ReminderScheduleItem {
                if let existing = reminders[reminder.eventKitItemID] {
                    if reminder.reminderStorageRecord.modificationDate.isAfterDate(existing.modificationDate) {
                        reminders[reminder.eventKitItemID] = reminder.reminderStorageRecord
                    }
                } else {
                    reminders[reminder.eventKitItemID] = reminder.reminderStorageRecord
                }
            }
        }

        self.calendars = Self.calendarList(fromCalendarGroups: schedule.calendars.calendarGroups)
        self.delegateCalendars = Self.calendarList(fromCalendarGroups: schedule.calendars.delegateCalendarGroups)
        self.events = events
        self.reminders = reminders
    }

    public init() {
        self.calendars = [:]
        self.delegateCalendars = [:]
        self.events = [:]
        self.reminders = [:]
    }

    private static func calendarList(fromCalendarGroups groups: [CalendarGroup]) -> [String: ScheduleCalendarStorageRecord] {
        var calendarsList: [String: ScheduleCalendarStorageRecord] = [:]

        groups.forEach {
            $0.calendars.forEach {
                calendarsList[$0.id] = $0.storageRecord
            }
        }

        return calendarsList
    }

    public var enabledCalendars: [String] {
        self.enabledCalendars(inGroups: self.calendars)
    }

    public var enabledDelegateCalendars: [String] {
        self.enabledCalendars(inGroups: self.delegateCalendars)
    }

    private func enabledCalendars(inGroups groups: [String: ScheduleCalendarStorageRecord]) -> [String] {
        var outCalendars: [String] = []

        groups.forEach { id, calendar in
            if calendar.isEnabled {
                outCalendars.append(id)
            }
        }

        return outCalendars
    }

    // MARK: - protocol conformance

    public var description: String {
        """
        \(type(of: self)): \
        calendars: \(self.calendars.count), \
        delegate calendars: \(self.delegateCalendars.count), \
        events: \(self.events.count), \
        reminders: \(self.reminders.count)
        """
    }
}

extension ScheduleStorageRecord: Codable {
    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case calendars
        case delegateCalendars
        case events
        case reminders
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.calendars = try values.decodeIfPresent([String: ScheduleCalendarStorageRecord].self, forKey: .calendars) ?? [:]
        self.delegateCalendars = try values.decodeIfPresent([String: ScheduleCalendarStorageRecord].self, forKey: .delegateCalendars) ?? [:]
        self.events = try values.decodeIfPresent([String: EventScheduleItemStorageRecord].self, forKey: .events) ?? [:]
        self.reminders = try values.decodeIfPresent([String: ReminderScheduleItemStorageRecord].self, forKey: .reminders) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.calendars, forKey: .calendars)
        try container.encode(self.delegateCalendars, forKey: .delegateCalendars)
        try container.encode(self.events, forKey: .events)
        try container.encode(self.reminders, forKey: .reminders)
    }
}

extension EventKitRules {
    public init(withStoredScheduleData scheduleData: ScheduleStorageRecord, visibleDayCount: Int) {
        self.init(enabledCalendars: Set(scheduleData.enabledCalendars),
                  enabledDelegateCalendars: Set(scheduleData.enabledDelegateCalendars),
                  visibleDayCount: visibleDayCount)
    }
}

extension Schedule {
    public func createStorageRecord() -> ScheduleStorageRecord {
        ScheduleStorageRecord(withSchedule: self)
    }
}
