//
//  RCCalendarItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol CalendarItemBehavior {
    var timeLabelDisplayString: String { get }
}

public protocol RCCalendarItem: CalendarItemBehavior, RCAbstractCalendarItem {
    
    var id: String { get }

    var externalIdentifier: String { get }
    
    var alarm: RCAlarm { get set }
    
    var title: String { get }
    
    var calendar: RCCalendar { get }
    
    var location: String? { get }
    
    var notes: String? { get }
    
    var url: URL? { get }
    
    var isSubscribed: Bool { get set }
    
    var isRecurring: Bool { get }
    
    var creationDate: Date? { get }
    
    var hasChanges: Bool { get }
    
    var hasParticipants: Bool { get }
    
    var participants: [RCParticipant] { get }
    
    var length: TimeInterval { get }

    var isAllDay: Bool { get }
}

extension RCCalendarItem {

    public var hasDates: Bool {
        return self.alarm.startDate != nil && self.alarm.endDate != nil
    }
        
    public var currentUser: RCParticipant? {
        if self.hasParticipants {
            for participant in self.participants {
                if participant.isCurrentUser {
                    return participant
                }
            }
        }
        
        return nil
    }
    
    public var settings: EKDataModelSettings {
        return self.calendar.settings
    }
}

