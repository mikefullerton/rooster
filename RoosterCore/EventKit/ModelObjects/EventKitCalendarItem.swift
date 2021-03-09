//
//  EventKitCalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol EventKitCalendarItem: EventKitWriteable, AbstractEquatable, StringIdentifiable {
    var externalIdentifier: String { get }

    var title: String { get }

    var calendar: EventKitCalendar { get }

    var location: String? { get }

    var notes: String? { get }

    var url: URL? { get }

    var isRecurring: Bool { get }

    var hasParticipants: Bool { get }

    var participants: [EventKitParticipant] { get }

    var isAllDay: Bool { get }

    var creationDate: Date? { get }

    var lastModifiedDate: Date? { get }
}

extension EventKitCalendarItem {
    public var currentUser: EventKitParticipant? {
        if self.hasParticipants {
            for participant in self.participants where participant.isCurrentUser {
                return participant
            }
        }

        return nil
    }
}
