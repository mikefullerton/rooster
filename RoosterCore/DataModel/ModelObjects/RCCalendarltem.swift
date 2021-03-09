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

public protocol RCCalendarItem: CustomStringConvertible, Loggable, CalendarItemBehavior {
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
    
    var startDate: Date { get }
    var endDate: Date { get }
}

extension RCCalendarItem {

    public var isHappeningNow: Bool {
        let now = Date()
        return now.isEqualToOrAfterDate(self.startDate) && now.isEqualToOrBeforeDate(self.endDate)
    }

    public var willHappen: Bool {
        let now = Date()
        return now.isBeforeDate(self.startDate)
    }
    
    public var didHappen: Bool {
        let now = Date()
        return now.isAfterDate(self.endDate)
    }
    
    public var startDate: Date {
        return self.alarm.startDate
    }
    
    public var endDate: Date {
        return self.alarm.endDate
    }

}

