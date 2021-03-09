//
//  RCDemoEvent.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/9/21.
//

import Foundation

public struct RCDemoEvent : Identifiable, Hashable, RCCalendarItem {
    
    
    public typealias ID = String
    
    public var id: String
    
    public var externalIdentifier: String
    
    public var alarm: RCAlarm
    
    public var title: String
    
    public var calendar: RCCalendar
    
    public var location: String?
    
    public var notes: String?
    
    public var url: URL?
    
    public var isSubscribed: Bool
    
//    public func isEqualTo(_ item: RCCalendarItem) -> Bool {
//        return self.id == item.id
//    }
//    
    public var startDate: Date
    
    public var endDate: Date
    
    public var description: String {
        return "demo"
    }
    
    public func stopAlarmButtonClicked() {
        
    }
    
    public var timeLabelDisplayString: String {
        return ""
    }
    
    init(withID id: String,
         alarm: RCAlarm,
         title: String,
         calendar: RCDemoCalendar,
         startDate: Date,
         endDate: Date,
         location: String) {
        
        self.id = id
        self.externalIdentifier = "external " + id
        self.alarm = alarm
        self.title = title
        self.calendar = calendar
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = nil
        self.isSubscribed = true
        
        
    }
    
    public static func == (lhs: RCDemoEvent, rhs: RCDemoEvent) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
}
