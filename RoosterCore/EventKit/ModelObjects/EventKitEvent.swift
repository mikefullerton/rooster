//
//  EventKitEvent.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import EventKit
import Foundation

import RoosterCore.Private

public struct EventKitEvent: Identifiable, Hashable, EventKitCalendarItem, Equatable, CustomStringConvertible {
    // MARK: - read only properties

    public let calendar: EventKitCalendar

    public let id: String

    public let ekEvent: EKEvent

    public var organizer: EventKitParticipant?

    public let externalIdentifier: String

    public let isDetached: Bool

    public let occurenceDate: Date?

    public let isRecurring: Bool

    public var hasParticipants: Bool

    public var participants: [EventKitParticipant]

    public let timeZone: TimeZone?

    public let creationDate: Date?

    public var lastModifiedDate: Date?

    // swiftlint:disable todo
    // TODO: show special birthday banners?
    // swiftlint:enable todo
    public let birthdayContactIdentifier: String?

    public let status: EventStatus

    // MARK: - modifiable eventKit properties

    public var startDate: Date

    public var endDate: Date

    public var title: String

    public var location: String?

    public var url: URL?

    public var notes: String?

    public var participationStatus: ParticipantStatus

    public let allowsParticipationStatusModifications: Bool

    public var availability: EventAvailability

    public var isAllDay: Bool

    public var isMultiDay: Bool {
        if let days = Date.daysBetween(lhs: self.startDate, rhs: self.endDate) {
            return days > 1
        }

        return false
    }

    public var hasChanges: Bool {
        self.ekEvent.startDate != self.startDate ||
        self.ekEvent.endDate != self.endDate ||
        self.ekEvent.title != self.title ||
        self.ekEvent.location != self.location ||
        self.ekEvent.notes != self.notes ||
        self.ekEvent.participationStatus_ != EKParticipantStatus(rawValue: self.participationStatus.rawValue) ||
        self.ekEvent.availability != EKEventAvailability(rawValue: self.availability.rawValue) ||
        self.ekEvent.isAllDay != self.isAllDay
    }

    public init(ekEvent: EKEvent,
                calendar: EventKitCalendar) {
        // readonly
        self.calendar = calendar
        self.id = ekEvent.uniqueID
        self.ekEvent = ekEvent
        self.organizer = ekEvent.organizer != nil ? EventKitParticipant(ekParticipant: self.ekEvent.organizer!) : nil
        self.externalIdentifier = ekEvent.calendarItemExternalIdentifier
        self.isDetached = ekEvent.isDetached
        self.occurenceDate = ekEvent.nullableOccurenceDate
        self.isRecurring = ekEvent.hasRecurrenceRules
        self.hasParticipants = ekEvent.hasAttendees
        self.participants = ekEvent.attendees?.map { EventKitParticipant(ekParticipant: $0) } ?? []
        self.allowsParticipationStatusModifications = ekEvent.allowsParticipationStatusModifications_
        self.lastModifiedDate = ekEvent.lastModifiedDate
        self.timeZone = ekEvent.timeZone
        self.creationDate = ekEvent.creationDate
        self.birthdayContactIdentifier = self.ekEvent.birthdayContactIdentifier
        self.lastModifiedDate = ekEvent.lastModifiedDate

        // modifiable
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.title = ekEvent.title
        self.location = ekEvent.location
        self.url = ekEvent.url
        self.notes = ekEvent.notes
        self.status = EventStatus(rawValue: self.ekEvent.status.rawValue) ?? .none
        self.participationStatus = ParticipantStatus(rawValue: ekEvent.participationStatus_.rawValue) ?? .unknown
        self.availability = EventAvailability(rawValue: ekEvent.availability.rawValue) ?? .notSupported
        self.isAllDay = ekEvent.isAllDay
    }

    public var description: String {
        """
        \(type(of: self)): \
        calendar: \(self.calendar.description) \
        title: \(self.title), \
        startDate: \(self.startDate.shortDateAndLongTimeString), \
        endDate: \(self.endDate.shortDateAndLongTimeString)
        """
    }

    public func occursBetween(startDate: Date, endDate: Date) -> Bool {
        Date.range(self.startDate...self.endDate, intersectsRange: startDate...endDate)
    }

    public static func == (lhs: EventKitEvent, rhs: EventKitEvent) -> Bool {
        lhs.calendar.id == rhs.calendar.id &&
        lhs.id == rhs.id &&
        lhs.organizer == rhs.organizer &&
        lhs.externalIdentifier == rhs.externalIdentifier &&
        lhs.occurenceDate == rhs.occurenceDate &&
        lhs.participants == rhs.participants &&
        lhs.lastModifiedDate == rhs.lastModifiedDate &&
        lhs.timeZone == rhs.timeZone &&
        lhs.creationDate == rhs.creationDate &&

        // modifiable
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.title == rhs.title &&
        lhs.location == rhs.location &&
        lhs.url == rhs.url &&
        lhs.notes == rhs.notes &&
        lhs.status == rhs.status &&
        lhs.participationStatus == rhs.participationStatus &&
        lhs.availability == rhs.availability &&
        lhs.isAllDay == rhs.isAllDay
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public func isEqual(to calendarItem: AbstractEquatable) -> Bool {
        guard let otherEvent = calendarItem as? EventKitEvent else { return false }
        return self == otherEvent
    }
}

extension EventKitEvent {
    public func saveEventKitObject() throws {
        guard self.hasChanges else {
            return
        }

        let eventStore = self.calendar.ekEventStore

        let ekEvent = self.updateEKEvent()

        try eventStore.save(ekEvent, span: .thisEvent, commit: true)
    }

    func updateEKEvent() -> EKEvent {
        self.ekEvent.startDate = self.startDate
        self.ekEvent.endDate = self.endDate
        self.ekEvent.title = self.title
        self.ekEvent.location = self.location
        self.ekEvent.url = self.url
        self.ekEvent.notes = self.notes
        self.ekEvent.participationStatus_ = EKParticipantStatus(rawValue: self.participationStatus.rawValue) ?? .unknown
        self.ekEvent.isAllDay = self.isAllDay
        self.ekEvent.availability = EKEventAvailability(rawValue: self.availability.rawValue) ?? .notSupported

        return self.ekEvent
    }
}
