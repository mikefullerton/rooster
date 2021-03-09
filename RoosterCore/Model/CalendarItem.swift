//
//  CalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/18/21.
//

import Foundation

public protocol CalendarItem: StringIdentifiable, AbstractEquatable, CustomStringConvertible, Loggable {
    var calendar: Calendar { get }

    var title: String { get }

    var location: String? { get }

    var notes: String? { get }

    var url: URL? { get }

    var isRecurring: Bool { get }

    var hasParticipants: Bool { get }

    var participants: [Participant] { get }

    var isAllDay: Bool { get }

    var isMultiday: Bool { get }

    var creationDate: Date? { get }

    var lastModifiedDate: Date? { get }

    var scheduleStartDate: Date? { get }

    var currentUser: Participant? { get }
}

extension CalendarItem {
    public var currentUser: Participant? {
        if self.hasParticipants {
            for participant in self.participants where participant.isCurrentUser {
                return participant
            }
        }

        return nil
    }
}
