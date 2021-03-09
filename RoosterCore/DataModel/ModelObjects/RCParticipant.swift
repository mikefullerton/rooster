//
//  RCParticipant.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

import Foundation
import EventKit

public struct RCParticipant: CustomStringConvertible, Equatable {
 
    private let participant: EKParticipant
    
    public var url: URL {
        return self.participant.url
    }
    
    public var name: String {
        return self.participant.name ?? ""
    }

    public var status: Status {
        return Status(rawValue: self.participant.participantStatus.rawValue) ?? .unknown
    }

    public var role: Role {
        return Role(rawValue: self.participant.participantRole.rawValue) ?? .unknown
    }

    public var kind: Kind {
        return Kind(rawValue: self.participant.participantType.rawValue) ?? .unknown
    }

    public var isCurrentUser: Bool {
        return self.participant.isCurrentUser
    }
    
    public var contactPredicate: NSPredicate {
        return self.participant.contactPredicate
    }
    
    public init(ekParticipant: EKParticipant) {
        self.participant = ekParticipant
    }
    
    public var description: String {
        return """
        type(of(self)): \
        name: \(self.name), \
        status: \(self.status.description), \
        role: \(self.role.description), \
        type: \(self.kind.description), \
        isCurrentUser: \(self.isCurrentUser), \
        url: \(self.url)
        """
    }
}

extension RCParticipant {
    public enum Status : Int, CustomStringConvertible, Codable {
        case unknown            = 0
        case pending            = 1
        case accepted           = 2
        case declined           = 3
        case tentative          = 4
        case delegated          = 5
        case completed          = 6
        case inProcess          = 7

        public var description: String {
            switch(self) {
            case .unknown:
                return "unknown"
            case .pending:
                return "pending"
            case .accepted:
                return "accepted"
            case .declined:
                return "declined"
            case .tentative:
                return "tentative"
            case .delegated:
                return "delegated"
            case .completed:
                return "completed"
            case .inProcess:
                return "inProcess"
            }
        }
    }
    
    public enum Role : Int, CustomStringConvertible, Codable {
        case unknown            = 0
        case required           = 1
        case optional           = 2
        case chair              = 3
        case nonParticipant     = 4

        public var description: String {
            switch(self) {
            case .unknown:
                return "unknown"
            case .required:
                return "required"
            case .optional:
                return "optional"
            case .chair:
                return "chair"
            case .nonParticipant:
                return "nonParticipant"
            }
        }
    }

    public enum Kind: Int, CustomStringConvertible, Codable {
        case unknown            = 0
        case person             = 1
        case room               = 2
        case resource           = 3
        case group              = 4
        
        public var description: String {
            switch(self) {
            case .unknown:
                return "unknown"
            case .person:
                return "person"
            case .room:
                return "room"
            case .resource:
                return "resource"
            case .group:
                return "group"

            }
        }
    }


}
