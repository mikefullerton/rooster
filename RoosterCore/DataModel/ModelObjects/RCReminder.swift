//
//  RCReminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

public struct RCReminder: Identifiable, Hashable, RCCalendarItem, Equatable {

    public let calendar: RCCalendar
    public let id: String
    public let ekReminder: EKReminder

    // modifiable
    public var isSubscribed: Bool
    public var alarm: RCAlarm
    
    public let startDate: Date
    
    public let endDate: Date
    
    /// MARK - EKEvent wrappers
    
    public var dueDate: Date {
        return self.startDate
    }
    
    public var isCompleted: Bool {
        return self.ekReminder.isCompleted
    }

    public var title: String {
        return self.ekReminder.title
    }
    
    public var ekReminderID: String {
        return self.ekReminder.calendarItemIdentifier
    }
    
    public var location: String? {
        return self.ekReminder.location
    }
    
    public var url: URL? {
        return self.ekReminder.url
    }
    
    public var notes: String? {
        return self.ekReminder.notes
    }
    
    public var externalIdentifier: String {
        return self.ekReminder.calendarItemExternalIdentifier
    }
    
    public var priority: Priority {
        return Priority(rawValue: self.ekReminder.priority) ?? .none
    }
    
    public var isRecurring: Bool {
        return false
    }
    
    public init(withIdentifier identifier: String,
                ekReminder: EKReminder,
                calendar: RCCalendar,
                subscribed: Bool,
                alarm: RCAlarm) {

        let startDate = ekReminder.dueDateComponents!.date!
        let endDate = startDate.addingTimeInterval(60 * 30)
        
        self.startDate = startDate
        self.endDate = endDate
        
        self.ekReminder = ekReminder
        self.calendar = calendar
        self.id = identifier
        self.isSubscribed = subscribed
        self.alarm = RCAlarm(startDate: startDate,
                             endDate: endDate,
                             enabled: alarm.isEnabled,
                             canExpire: false,
                             behavior:  .fireOnce,
                             isFinished: alarm.isFinished,
                             finishedDate: alarm.finishedDate)
    }

    public var description: String {
        return "\(type(of:self)): \(self.title), Calendar: \(self.calendar)"
    }
    
    public static func == (lhs: RCReminder, rhs: RCReminder) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.calendar.id == rhs.calendar.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.isCompleted == rhs.isCompleted &&
                lhs.endDate == rhs.endDate &&
                lhs.startDate == rhs.startDate  &&
                lhs.externalIdentifier == rhs.externalIdentifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
//    public func isEqualTo(_ item: RCCalendarItem) -> Bool {
//        if let comparingTo = item as? RCReminder {
//            return self == comparingTo
//        }
//        return false
//    }
}

extension RCReminder {
    public var timeLabelDisplayString: String {
        return "RCReminder Due at: \(self.alarm.startDate))"
    }
}

extension RCReminder {
    public func update(withSavedState savedState: CalendarItemStorageRecord) -> RCReminder {

        return RCReminder(withIdentifier: self.id,
                          ekReminder:self.ekReminder,
                          calendar: self.calendar,
                          subscribed: savedState.isSubscribed,
                          alarm: savedState.alarm)

    }
    
    public init(withReminder ekReminder: EKReminder,
                calendar: RCCalendar,
                startDate: Date,
                endDate: Date,
                savedState: CalendarItemStorageRecord) {

        self.init(withIdentifier: ekReminder.uniqueID,
                  ekReminder: ekReminder,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: savedState.alarm)

    }
}

extension RCReminder {
    
    public enum Priority : Int, CustomStringConvertible, Codable {
        case none               = 0
        case high               = 1
        case medium             = 5
        case low                = 9
        
        public var description: String {
            switch self  {
            case .none:
                return "none"
            case .high:
                return "high"
            case .medium:
                return "medium"
            case .low:
                return "low"
            }
        }

    }
}
