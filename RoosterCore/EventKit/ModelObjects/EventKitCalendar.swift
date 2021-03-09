//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import EventKit
import Foundation

public struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable, Calendar {
    internal let ekEventStore: EKEventStore
    private let ekCalendar: EKCalendar

    public let source: CalendarSource
    public let id: String
    public let allowsEvents: Bool
    public let allowsReminders: Bool
    public let isReadOnly: Bool

    // EKCalendar Modifiable
    public var title: String

    public var cgColor: CGColor?

    public var color: SDKColor? {
        get { self.cgColor == nil ? nil : SDKColor(cgColor: self.cgColor!) }
        set { self.cgColor = newValue?.cgColor }
    }

//    public var typeDisplayName: String {
//        "Calendar"
//    }

    public init(withIdentifier identifier: String,
                ekCalendar: EKCalendar,
                ekEventStore: EKEventStore) {
        self.title = ekCalendar.title
        self.cgColor = ekCalendar.cgColor
        self.id = identifier
        self.ekCalendar = ekCalendar
        self.ekEventStore = ekEventStore
        self.source = EventKitCalendarSource(eventKitCalendarSource: ekCalendar.source)
        self.allowsEvents = ekCalendar.allowedEntityTypes.contains(.event)
        self.allowsReminders = ekCalendar.allowedEntityTypes.contains(.reminder)
        self.isReadOnly = ekCalendar.allowsContentModifications == false
    }

    public var description: String {
        "\(type(of: self)): \(self.source.title): \(self.title)"
    }

    public static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.source.isEqual(to: rhs.source) &&
        lhs.ekEventStore.eventStoreIdentifier == rhs.ekEventStore.eventStoreIdentifier &&
        lhs.cgColor == rhs.cgColor
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public var hasChanges: Bool {
        self.title != self.ekCalendar.title ||
        self.cgColor != self.ekCalendar.cgColor
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let otherCalendar = scheduleItem as? EventKitCalendar else { return false }
        return otherCalendar == self
    }
}

extension EventKitCalendar: EventKitWriteable {
    public func saveEventKitObject() throws {
        guard self.hasChanges else {
            return
        }

        let ekCalendar = self.updateEKCalendar()
        if ekCalendar.hasChanges {
            try self.ekEventStore.saveCalendar(ekCalendar, commit: true)
        }
    }

    func updateEKCalendar() -> EKCalendar {
        self.ekCalendar.title = self.title
        self.ekCalendar.cgColor = self.cgColor

        return self.ekCalendar
    }
}
