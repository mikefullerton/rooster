//
//  Calender.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

public struct RCCalendar: RCAbstractCalendarItem, Identifiable, CustomStringConvertible, Equatable, Hashable  {

    public let id: String
    public let ekCalendar: EKCalendar
    public let ekEventStore: EKEventStore
    public let settings: EKDataModelSettings
    
    // modifiable
    public var isSubscribed: Bool

    // EKCalendar Modifiable
    public var title: String

    public var cgColor: CGColor?

    public var sourceIdentifier: String {
        return self.ekCalendar.source.sourceIdentifier
    }
    
    public var sourceTitle: String {
        return self.ekCalendar.source.title
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
    
    public var typeDisplayName: String {
        return "Calendar"
    }
    
    public init(withIdentifier identifier: String,
                ekCalendar: EKCalendar,
                ekEventStore: EKEventStore,
                settings: EKDataModelSettings,
                isSubscribed: Bool) {
        
        self.title = ekCalendar.title
        self.cgColor = ekCalendar.cgColor
        self.id = identifier
        self.ekCalendar = ekCalendar
        self.isSubscribed = isSubscribed
        self.ekEventStore = ekEventStore
        self.settings = settings
    }
    
    public var description: String {
        return "\(type(of:self)): \(self.sourceTitle): \(self.title), isSubscribed: \(self.isSubscribed)"
    }
    
    public static func == (lhs: RCCalendar, rhs: RCCalendar) -> Bool {
        
        
        if lhs.title == rhs.title {
            let same = lhs.cgColor == rhs.cgColor
            print ("CALENDAR: \(lhs.title) \(same) \(String(describing: lhs.cgColor)) \(String(describing: rhs.cgColor))")
        }
        
        return  lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.sourceTitle == rhs.sourceTitle &&
                lhs.sourceIdentifier == rhs.sourceIdentifier &&
                lhs.ekEventStore.eventStoreIdentifier == rhs.ekEventStore.eventStoreIdentifier &&
                lhs.cgColor == rhs.cgColor
    }
 
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public var hasChanges: Bool {
        return  self.title != self.ekCalendar.title ||
                self.cgColor != self.ekCalendar.cgColor
    }
    
    
}


