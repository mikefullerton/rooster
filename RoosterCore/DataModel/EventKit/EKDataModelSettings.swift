//
//  EKDataModelSettings.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation

public struct EKDataModelSettings: Equatable, Codable, CustomStringConvertible {
    
    // events
    public var allDayEvents: Bool
    public var declinedEvents: Bool

    // reminders
    public var remindersWithNoDates: Bool
    public var remindersDuration: TimeInterval
    public var timelessRemindersStart: TimeDescriptor
    
    // misc
    public var startingDay: Date?
    public var dayCount: Int
    public var workdayStart: TimeDescriptor
    public var workdayEnd: TimeDescriptor
    
    public init(startingDay: Date?,
                dayCount: Int,
                allDayEvents: Bool,
                declinedEvents: Bool,
                remindersWithNoDates: Bool,
                remindersDuration: TimeInterval,
                timelessRemindersStart: TimeDescriptor,
                workdayStart: TimeDescriptor,
                workdayEnd: TimeDescriptor) {
        
        self.startingDay = startingDay
        self.dayCount = dayCount
        self.allDayEvents = allDayEvents
        self.declinedEvents = declinedEvents
        self.remindersWithNoDates = remindersWithNoDates
        self.remindersDuration = remindersDuration
        self.timelessRemindersStart = timelessRemindersStart
        self.workdayStart = workdayStart
        self.workdayEnd = workdayEnd
    }
    
    public init() {
        self.init( startingDay: nil,
                   dayCount: 1,
                   allDayEvents: true,
                   declinedEvents: false,
                   remindersWithNoDates: true,
                   remindersDuration: Date.minutesToInterval(15),
                   timelessRemindersStart: TimeDescriptor(hour: 10, minute: 0, part: .am),
                   workdayStart: TimeDescriptor(hour: 10, minute: 0, part: .am),
                   workdayEnd: TimeDescriptor(hour: 6, minute: 0, part: .pm))
    }
    
    public static let `default` = EKDataModelSettings()
    
    public var description: String {
        return """
        type(of: self): \
        dayCount: \(self.dayCount) \
        allDayEvents: \(self.allDayEvents) \
        declinedEvents: \(self.declinedEvents) \
        startingDay: \(self.startingDay?.shortDateAndLongTimeString ?? "default") \
        remindersWithNoDates: \(self.remindersWithNoDates) \
        remindersDuration: \(self.remindersDuration) \
        timelessRemindersStart: \(self.timelessRemindersStart) \
        workDayStart: \(self.workdayStart)  \
        workDayEnd: \(self.workdayEnd)
        """
    }
}

extension EKDataModelSettings {
    public struct TimeDescriptor: Codable, Equatable, CustomStringConvertible {
        
        public enum DayHalf: Int, Codable, CustomStringConvertible, Equatable {
            case am
            case pm
            
            public var description: String {
                switch(self) {
                case .am:
                    return "AM"
                case .pm:
                    return "PM"
                }
            }
        }
        
        public var hour: Int
        public var minute: Int
        public var part: DayHalf
       
        public var description: String {
            return "\(hour):\(minute) \(self.part.description)"
        }
        
//        public static func != (lhs: Self, rhs: Self) -> Bool {
//
//            return  lhs.hour == rhs.hour &&
//                    lhs.minute == rhs.minute &&
//                    lhs.part == rhs.part
//        }


    }
}
