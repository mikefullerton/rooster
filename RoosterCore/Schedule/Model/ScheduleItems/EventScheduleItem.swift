//
//  EventScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

public struct EventScheduleItem: ScheduleItem, StorableScheduleItem, Equatable, Identifiable {
    public typealias ID = String

    public let id: ID

    public var alarm: ScheduleItemAlarm? {
        didSet {
            self.eventStorageRecord.finishedDate = self.alarm?.finishedDate
        }
    }

    fileprivate var eventKitEvent: EventKitEvent

    internal var eventStorageRecord: EventScheduleItemStorageRecord

    internal var storageRecord: ScheduleItemStorageRecord {
        self.eventStorageRecord
    }

    public var calendar: Calendar

    public var dateRange: DateRange? {
        assert(self.alarm != nil || self.isAllDay, "alarm should not be nil")
        return self.alarm?.dateRange
    }

    public var isEnabled: Bool {
        get { self.eventStorageRecord.isEnabled }
        set { self.eventStorageRecord.isEnabled = newValue }
    }

    public var eventKitItemID: String {
        self.eventKitEvent.id
    }

    public let canExpire = true

//    public internal(set) var scheduleItemStorageRecord: ScheduleItemStorageRecord

    public internal(set) var scheduleDay: Date?

    public let isAllDay: Bool

    public var isMultiday: Bool {
        self.eventDateRange.isMultiDay
    }

    public var eventDateRange: DateRange

    // MARK: - display

    public var timeLabelDisplayString: String {
        let startTime = self.dateRange?.startDate.shortTimeString ?? ""
        let endTime = self.dateRange?.endDate.shortTimeString ?? ""

        return "\(startTime) - \(endTime)"
    }

    public var typeDisplayName: String {
        "Event"
    }

    public var title: String {
        get { self.eventKitEvent.title }
        set { self.eventKitEvent.title = newValue }
    }

    public var notes: String? {
        get { self.eventKitEvent.notes }
        set { self.eventKitEvent.notes = newValue }
    }

    public var url: URL? {
        get { self.eventKitEvent.url }
        set { self.eventKitEvent.url = newValue }
    }

    public var location: String? {
        get { self.eventKitEvent.location }
        set { self.eventKitEvent.location = newValue }
    }

    public var isRecurring: Bool {
        self.eventKitEvent.isRecurring
    }

    public var participationStatus: ParticipantStatus {
        get { self.eventKitEvent.participationStatus }
        set { self.eventKitEvent.participationStatus = newValue }
    }

    public var allowsParticipationStatusModifications: Bool {
        self.eventKitEvent.allowsParticipationStatusModifications
    }

    public var currentUser: Participant? {
        self.eventKitEvent.currentUser
    }

    public var creationDate: Date? {
        self.eventKitEvent.creationDate
    }

    public var lastModifiedDate: Date? {
        self.eventKitEvent.lastModifiedDate
    }

    public var hasParticipants: Bool {
        self.eventKitEvent.hasParticipants
    }

    public var participants: [Participant] {
        self.eventKitEvent.participants
    }

    public var scheduleStartDate: Date? {
        self.dateRange?.startDate
    }

    // MARK: - protocols

    public var description: String {
        """
        \(type(of: self)) \
        id: \(self.id), \
        event: \(self.eventKitEvent.description) \
        alarm: \(self.alarm?.description ?? "no alarm") \
        storage record: \(self.eventStorageRecord.description)
        """
    }

    public static func == (lhs: EventScheduleItem, rhs: EventScheduleItem) -> Bool {
        lhs.eventKitEvent == rhs.eventKitEvent &&
        lhs.calendar.isEqual(to: rhs.calendar) &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.alarm == rhs.alarm &&
        lhs.dateRange == rhs.dateRange &&
        lhs.id == rhs.id &&
        lhs.eventStorageRecord == rhs.eventStorageRecord
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let other = scheduleItem as? Self else { return false }
        return self == other
    }

    public func saveEventKitObject() throws {
        try self.eventKitEvent.saveEventKitObject()
    }

    public var hasEventKitObjectChanges: Bool {
        self.eventKitEvent.hasChanges
    }
}

extension EventScheduleItem {
    public init(withEvent event: EventKitEvent,
                calendar: ScheduleCalendar,
                dateRange: DateRange,
                storageRecord: EventScheduleItemStorageRecord,
                scheduleBehavior: ScheduleBehavior) {
        self.id = String.guid
        self.calendar = calendar
        self.eventKitEvent = event
        self.eventStorageRecord = storageRecord

        let isAllDay = event.isAllDay || dateRange.isAllDay

        var alarm: ScheduleItemAlarm?

        if isAllDay {
            if scheduleBehavior.eventScheduleBehavior.scheduleAllDayEvents {
                let workDayRange = scheduleBehavior.calendarScheduleBehavior.workdayDateRange
                alarm = ScheduleItemAlarm(dateRange: workDayRange,
                                          finishedDate: storageRecord.finishedDate)
            }

            // don't show on schedule
        } else {
            alarm = ScheduleItemAlarm(dateRange: dateRange,
                                      finishedDate: storageRecord.finishedDate)
        }

        self.eventDateRange = DateRange(startDate: event.startDate, endDate: event.endDate)
        self.isAllDay = isAllDay
        self.scheduleDay = dateRange.startDate.midnight
        self.alarm = alarm
    }
}
