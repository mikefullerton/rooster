//
//  EventKitReminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import EventKit
import Foundation

public struct EventKitReminder: Identifiable, Hashable, EventKitCalendarItem, Equatable, Reminder {
    public typealias ID = String

    public let id: ID

    public var calendar: Calendar

//    public let calendar: EventKitCalendar

    public let ekReminder: EKReminder

    public let externalIdentifier: String

    public let isRecurring: Bool

    public let hasParticipants: Bool

    public let participants: [Participant]

    public let timeZone: TimeZone?

    // NOTE: use scheduleStartDate
    public var startDate: Date?

    // NOTE: use scheduleStartDate
    public var dueDate: Date?

    public var creationDate: Date?

    public var lastModifiedDate: Date?

    public var scheduleStartDate: Date? {
        get { self.startDate ?? self.dueDate }
        set {
            // FUTURE: still don't understand difference between startDate and dueDate
            self.startDate = newValue
            self.dueDate = newValue
        }
    }

    public var isCompleted: Bool {
        didSet {
            if oldValue != self.isCompleted, self.isCompleted && self.completionDate == nil {
                self.completionDate = Date()
            }
        }
    }

    public var title: String

    public var location: String?

    public var url: URL?

    public var notes: String?

    public var priority: ReminderPriority

    public var completionDate: Date? {
        didSet {
            if oldValue != self.completionDate, self.completionDate != nil, self.isCompleted == false {
                self.isCompleted = true
            }
        }
    }

    public var isAllDay: Bool {
        self.scheduleStartDate?.isMidnight ?? false
    }

    public var isMultiday: Bool {
        false
    }

    public var hasChanges: Bool {
        self.startDate != self.ekReminder.startDate ||
        self.isCompleted != self.ekReminder.isCompleted ||
        self.title != self.ekReminder.title ||
        self.location != self.ekReminder.location ||
        self.url != self.ekReminder.url ||
        self.notes != self.ekReminder.notes ||
        self.priority.rawValue != self.ekReminder.priority ||
        self.completionDate != self.ekReminder.completionDate ||
        self.dueDate != self.ekReminder.dueDate
    }

    public init(ekReminder: EKReminder,
                calendar: EventKitCalendar) {
        self.ekReminder = ekReminder
        self.calendar = calendar
        self.id = ekReminder.uniqueID
        self.creationDate = ekReminder.creationDate
        self.lastModifiedDate = ekReminder.lastModifiedDate
        self.externalIdentifier = ekReminder.calendarItemExternalIdentifier
        self.isRecurring = ekReminder.hasRecurrenceRules
        self.hasParticipants = ekReminder.hasAttendees
        self.participants = ekReminder.attendees?.map { EventKitParticipant(ekParticipant: $0) } ?? []
        self.lastModifiedDate = ekReminder.lastModifiedDate
        self.timeZone = ekReminder.timeZone

        // modifiable
        self.dueDate = ekReminder.dueDate
        self.startDate = ekReminder.startDate
        self.isCompleted = ekReminder.isCompleted
        self.title = ekReminder.title
        self.location = ekReminder.location
        self.url = ekReminder.url
        self.notes = ekReminder.notes
        self.priority = ReminderPriority(rawValue: ekReminder.priority) ?? .none
        self.completionDate = ekReminder.completionDate
    }

    public var description: String {
        """
        \(type(of: self)): \
        title: \(self.title), \
        startDate: \(self.startDate?.shortDateAndLongTimeString ?? "nil"), \
        dueDate: \(self.dueDate?.shortDateAndLongTimeString ?? "nil"), \
        Calendar: \(self.calendar.description)"
        """
    }

    public static func == (lhs: EventKitReminder, rhs: EventKitReminder) -> Bool {
        lhs.id == rhs.id &&
        lhs.calendar.isEqual(to: rhs.calendar) &&
        lhs.participants.isEqual(to: rhs.participants) &&
        lhs.lastModifiedDate == rhs.lastModifiedDate &&
        lhs.timeZone == rhs.timeZone &&
        lhs.creationDate == rhs.creationDate &&

        // modifiable
        lhs.startDate == rhs.startDate  &&
        lhs.dueDate == rhs.dueDate &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.title == rhs.title &&
        lhs.location == rhs.location &&
        lhs.url == rhs.url &&
        lhs.notes == rhs.notes &&
        lhs.priority == rhs.priority &&
        lhs.completionDate == rhs.completionDate
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public func isEqual(to calendarItem: AbstractEquatable) -> Bool {
        guard let otherEvent = calendarItem as? EventKitReminder else { return false }
        return self == otherEvent
    }
}

extension EKReminder {
    public var actualDueDate: Date? {
        self.dueDate ?? self.startDate
    }
}

extension EventKitReminder {
    func updateEKReminder() -> EKReminder {
        self.ekReminder.startDateComponents = self.startDate?.components
        self.ekReminder.title = self.title
        self.ekReminder.isCompleted = self.isCompleted
        self.ekReminder.location = self.location
        self.ekReminder.url = self.url
        self.ekReminder.notes = self.notes
        self.ekReminder.priority = self.priority.rawValue
        self.ekReminder.completionDate = self.completionDate
        self.ekReminder.dueDateComponents = self.dueDate?.components

        return self.ekReminder
    }

    public func saveEventKitObject() throws {
        guard self.hasChanges else {
            return
        }

        guard let eventKitCalendar = self.calendar as? EventKitCalendar else {
            return
        }

        let eventStore = eventKitCalendar.ekEventStore

        let ekReminder = self.updateEKReminder()

        try eventStore.save(ekReminder, commit: true)
    }
}
