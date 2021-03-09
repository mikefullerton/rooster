//
//  EventKitParticipant.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

import EventKit
import Foundation

public struct EventKitParticipant: CustomStringConvertible, Equatable {
    public let participant: EKParticipant

    public let url: URL?

    public let name: String

    public let participantStatus: ParticipantStatus

    public let participantRole: ParticipantRole

    public let participantType: ParticipantType

    public let isCurrentUser: Bool

    public let contactPredicate: NSPredicate

    // so far participants are immutable
    public var hasChanges: Bool {
        false
    }

    public init(ekParticipant: EKParticipant) {
        self.participant = ekParticipant

        self.url = ekParticipant.url
        self.name = ekParticipant.name ?? ""
        self.participantStatus = ParticipantStatus(rawValue: ekParticipant.participantStatus.rawValue) ?? .unknown
        self.participantRole = ParticipantRole(rawValue: ekParticipant.participantRole.rawValue) ?? .unknown
        self.participantType = ParticipantType(rawValue: ekParticipant.participantType.rawValue) ?? .unknown
        self.isCurrentUser = ekParticipant.isCurrentUser
        self.contactPredicate = ekParticipant.contactPredicate
    }

    public var description: String {
        """
        type(of(self)): \
        name: \(self.name), \
        status: \(self.participantStatus.description), \
        role: \(self.participantRole.description), \
        type: \(self.participantType.description), \
        isCurrentUser: \(self.isCurrentUser), \
        url: \(String(describing: self.url))
        """
    }

    public static func == (lhs: EventKitParticipant, rhs: EventKitParticipant) -> Bool {
        lhs.url == rhs.url &&
                lhs.name == rhs.name &&
                lhs.participantStatus == rhs.participantStatus &&
                lhs.participantRole == rhs.participantRole &&
                lhs.participantType == rhs.participantType
    }
}
