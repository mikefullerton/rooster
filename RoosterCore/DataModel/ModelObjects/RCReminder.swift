//
//  RCReminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

public struct RCReminder: Identifiable, Hashable, RCCalendarItem, Equatable {
    
    
    // read only properties
    
    public let id: String

    public let calendar: RCCalendar

    public let ekReminder: EKReminder

    public private(set) var endDate: Date? {
        didSet {
            self.updateCalculatedDates()
        }
    }
    
    public let externalIdentifier: String
    
    public let isRecurring: Bool

    public let hasParticipants: Bool
    
    public let participants: [RCParticipant]
    
    public let lastModifiedDate: Date?

    public let timeZone: TimeZone?

    public let creationDate: Date?
    
    public private(set) var isAllDay: Bool

    public var hasChanges: Bool {
        return  self.startDate != self.ekReminder.startDate ||
                self.isCompleted != self.ekReminder.isCompleted ||
                self.title != self.ekReminder.title ||
                self.location != self.ekReminder.location ||
                self.url != self.ekReminder.url ||
                self.notes != self.ekReminder.notes ||
                self.priority.rawValue != self.ekReminder.priority ||
                self.completionDate != self.ekReminder.completionDate ||
                self.dueDate != self.ekReminder.dueDate
    }

    public var typeDisplayName: String {
        return "Reminder"
    }

    public var timeLabelDisplayString: String {
        if  let startDate = self.startDate {
            return "RCReminder Due at: \(startDate))"
        }
        
        return ""
    }
    
    // modifiable
    public var isSubscribed: Bool

    public var alarm: RCAlarm

    public var startDate: Date? {
        didSet {
            self.updateCalculatedDates()
        }
    }
    
    public var dueDate: Date? {
        didSet {
            self.updateCalculatedDates()
        }
    }

    public var length: TimeInterval {
        didSet {
            self.updateCalculatedDates()
        }
    }
    
    public var isCompleted: Bool

    public var title: String
    
    public var location: String?
    
    public var url: URL?
    
    public var notes: String?
    
    public var priority: Priority
    
    public var completionDate: Date?

    public init(ekReminder: EKReminder,
                calendar: RCCalendar,
                subscribed: Bool,
                length: TimeInterval,
                alarm: RCAlarm) {

        self.ekReminder = ekReminder
        self.calendar = calendar
        self.id = ekReminder.uniqueID
        self.isSubscribed = subscribed
        self.length = length
        self.creationDate = ekReminder.creationDate
        self.dueDate = ekReminder.dueDate
        self.startDate = ekReminder.startDate
        self.isCompleted = ekReminder.isCompleted
        self.title = ekReminder.title
        self.location = ekReminder.location
        self.url = ekReminder.url
        self.notes = ekReminder.notes
        self.priority = Priority(rawValue: ekReminder.priority) ?? .none
        self.externalIdentifier = ekReminder.calendarItemExternalIdentifier
        self.isRecurring = ekReminder.hasRecurrenceRules
        self.completionDate = ekReminder.completionDate
        self.hasParticipants = ekReminder.hasAttendees
        self.participants = ekReminder.attendees?.map { RCParticipant(ekParticipant: $0) } ?? []
        self.lastModifiedDate = ekReminder.lastModifiedDate
        self.timeZone = ekReminder.timeZone
        
        // these will all get updated in updateCalculatedDates
        self.isAllDay = false
        self.endDate = self.startDate
        
        self.alarm = RCAlarm(startDate: self.startDate,
                             endDate: self.startDate,
                             enabled: alarm.isEnabled,
                             canExpire: false,
                             finishedDate: alarm.finishedDate)
        
        
        self.updateCalculatedDates()
    }

    public init(ekReminder: EKReminder,
                calendar: RCCalendar,
                subscribed: Bool,
                length: TimeInterval) {
        
        
        let alarm = RCAlarm(startDate: nil, // will be updated later
                             endDate: nil,
                             enabled: subscribed,
                             canExpire: false,
                             finishedDate: nil)

        
        self.init(ekReminder: ekReminder,
                  calendar: calendar,
                  subscribed: subscribed,
                  length: length,
                  alarm: alarm)
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        title: \(self.title), \
        startDate: \(self.startDate?.shortDateAndLongTimeString ?? "nil"), \
        endDate: \(self.endDate?.shortDateAndLongTimeString ?? "nil"), \
        dueDate: \(self.dueDate?.shortDateAndLongTimeString ?? "nil"), \
        length: \(self.length), \
        Calendar: \(self.calendar.description)" \
        alarm : \(self.alarm.description)" \
        isAllDay: \(self.isAllDay) \
        hasDates: \(self.hasDates)
        """
    }
    
    public static func == (lhs: RCReminder, rhs: RCReminder) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.calendar == rhs.calendar &&
                lhs.participants == rhs.participants &&
                lhs.lastModifiedDate == rhs.lastModifiedDate &&
                lhs.timeZone == rhs.timeZone &&
                lhs.creationDate == rhs.creationDate &&
        
                // modifiable
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.startDate == rhs.startDate  &&
                lhs.dueDate == rhs.dueDate &&
                lhs.length == rhs.length &&
                lhs.isCompleted == rhs.isCompleted &&
                lhs.title == rhs.title &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.priority == rhs.priority &&
                lhs.completionDate == rhs.completionDate
                
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    // private
    
    private mutating func updateCalculatedDates() {
        
        let endDate = self.dueDate?.addingTimeInterval(self.length)
        
        if self.endDate != endDate {
            self.endDate = endDate
        }

//        let dueDate = ekReminder.actualDueDate
//        let endDate = dueDate?.addingTimeInterval(length)
        
        self.alarm.startDate = self.startDate
        self.alarm.endDate = self.endDate
       
    }
}

extension EKReminder {
    var actualDueDate: Date? {
        return self.dueDate ?? self.startDate
    }
}

extension RCReminder {
    public func update(withSavedState savedState: ReminderStorageRecord) -> RCReminder {

        return RCReminder(ekReminder:self.ekReminder,
                          calendar: self.calendar,
                          subscribed: savedState.isSubscribed,
                          length: savedState.length,
                          alarm: savedState.alarm)

    }
    
    public init(ekReminder: EKReminder,
                calendar: RCCalendar,
                savedState: ReminderStorageRecord) {

        self.init(ekReminder: ekReminder,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  length: savedState.length,
                  alarm: savedState.alarm)
    }
}

extension RCReminder {
    
    public enum Priority : Int, CustomStringConvertible, Codable, Equatable {
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

        public static func == (lhs: Self, rhs: Self) -> Bool {
            return  lhs.rawValue == rhs.rawValue
        }

    }
}
