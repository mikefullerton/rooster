//
//  EventScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

public struct EventScheduleItem: ScheduleItem, Equatable {
    public let scheduleItemID: String

    public var alarm: ScheduleItemAlarm? {
        didSet {
            self.eventStorageRecord.finishedDate = self.alarm?.finishedDate
        }
    }

    // swiftlint:disable force_cast
    private var eventKitEvent: EventKitEvent {
        get { self.eventKitCalendarItem as! EventKitEvent }
        set { self.eventKitCalendarItem = newValue }
    }

    public var eventStorageRecord: EventScheduleItemStorageRecord {
        get { self.scheduleItemStorageRecord as! EventScheduleItemStorageRecord }
        set { self.scheduleItemStorageRecord = newValue }
    }

    // swiftlint:enable force_cast

    public var eventKitCalendarItem: EventKitCalendarItem

    public var calendar: CalendarScheduleItem

    public var dateRange: DateRange? {
        assert(self.alarm != nil || self.isAllDay, "alarm should not be nil")
        return self.alarm?.dateRange
    }

    public var isEnabled: Bool {
        get { self.scheduleItemStorageRecord.isEnabled }
        set { self.scheduleItemStorageRecord.isEnabled = newValue }
    }

    public var eventKitItemID: String {
        self.eventKitCalendarItem.id
    }

    public let canExpire = true

    public internal(set) var scheduleItemStorageRecord: ScheduleItemStorageRecord

    public internal(set) var scheduleDay: Date?

    public let isAllDay: Bool

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

    public var currentUser: EventKitParticipant? {
        self.eventKitEvent.currentUser
    }

    public var creationDate: Date? {
        self.eventKitEvent.creationDate
    }

    public var lastModificationDate: Date? {
        self.eventKitEvent.lastModifiedDate
    }

    // MARK: - protocols

    public var description: String {
        """
        \(type(of: self)) \
        scheduleItemID: \(self.scheduleItemID), \
        event: \(self.eventKitEvent.description) \
        alarm: \(self.alarm?.description ?? "no alarm") \
        storage record: \(self.eventStorageRecord.description)
        """
    }

    public static func == (lhs: EventScheduleItem, rhs: EventScheduleItem) -> Bool {
        lhs.eventKitEvent == rhs.eventKitEvent &&
        lhs.calendar == rhs.calendar &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.alarm == rhs.alarm &&
        lhs.dateRange == rhs.dateRange &&
        lhs.scheduleItemID == rhs.scheduleItemID &&
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
