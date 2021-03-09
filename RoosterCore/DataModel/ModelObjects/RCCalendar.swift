//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

public struct RCCalendar: Identifiable, CustomStringConvertible, Equatable, Hashable  {

    public let id: String
    public let ekCalendar: EKCalendar
    
    // modifiable
    public var isSubscribed: Bool

    public var title: String {
        return self.ekCalendar.title
    }

    public var sourceIdentifier: String {
        return self.ekCalendar.source.sourceIdentifier
    }
    
    public var sourceTitle: String {
        return self.ekCalendar.source.title
    }
    
    public var cgColor: CGColor? {
        return self.ekCalendar.cgColor
    }
    
    public var allowsEvents: Bool {
        return self.ekCalendar.allowedEntityTypes.contains(.event)
    }

    public var allowsReminders: Bool {
        return self.ekCalendar.allowedEntityTypes.contains(.reminder)
    }
    
    public var isReadOnly: Bool {
        return self.ekCalendar.allowsContentModifications == false
    }

    public init(withIdentifier identifier: String,
                ekCalendar: EKCalendar,
                isSubscribed: Bool) {
        
        self.id = identifier
        self.ekCalendar = ekCalendar
        self.isSubscribed = isSubscribed
    }
    
    public var description: String {
        return "\(type(of:self)): \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }
    
    public static func == (lhs: RCCalendar, rhs: RCCalendar) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.sourceTitle == rhs.sourceTitle &&
                lhs.sourceIdentifier == rhs.sourceIdentifier
    }
 
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}


