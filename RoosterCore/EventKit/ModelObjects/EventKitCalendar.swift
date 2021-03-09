//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import EventKit
import Foundation

public struct EventKitCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable {
    public let ekEventStore: EKEventStore
    public let ekCalendar: EKCalendar

    public let id: String

    // EKCalendar Modifiable
    public var title: String

    public var cgColor: CGColor?

    public var color: SDKColor? {
        get { self.cgColor == nil ? nil : SDKColor(cgColor: self.cgColor!) }
        set { self.cgColor = newValue?.cgColor }
    }

    public var sourceIdentifier: String {
        self.ekCalendar.source.sourceIdentifier
    }

    public var sourceTitle: String {
        self.ekCalendar.source.title
    }

    public var allowsEvents: Bool {
        self.ekCalendar.allowedEntityTypes.contains(.event)
    }

    public var allowsReminders: Bool {
        self.ekCalendar.allowedEntityTypes.contains(.reminder)
    }

    public var isReadOnly: Bool {
        self.ekCalendar.allowsContentModifications == false
    }

    public var typeDisplayName: String {
        "Calendar"
    }

    public init(withIdentifier identifier: String,
                ekCalendar: EKCalendar,
                ekEventStore: EKEventStore) {
        self.title = ekCalendar.title
        self.cgColor = ekCalendar.cgColor
        self.id = identifier
        self.ekCalendar = ekCalendar
        self.ekEventStore = ekEventStore
    }

    public var description: String {
        "\(type(of: self)): \(self.sourceTitle): \(self.title)"
    }

    public static func == (lhs: EventKitCalendar, rhs: EventKitCalendar) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.sourceTitle == rhs.sourceTitle &&
        lhs.sourceIdentifier == rhs.sourceIdentifier &&
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
