//
//  RCReminder.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

public struct RCReminder: Identifiable, Hashable, RCCalendarItem {
    
    public let calendar: RCCalendar
    public let id: String
    public let ekReminderID: String
    public let isCompleted: Bool
    public let title: String
    public let location: String?
    public let notes: String?
    public let url: URL?
    public let dueDate: Date
    public let startDate: Date
    public let externalIdentifier: String
    
    // modifiable
    public var isSubscribed: Bool
    public var alarm: RCAlarm

    public init(withIdentifier identifier: String,
                ekReminderID: String,
                externalIdentifier: String,
                calendar: RCCalendar,
                subscribed: Bool,
                completed: Bool,
                alarm: RCAlarm,
                startDate: Date,
                dueDate: Date,
                title: String,
                location: String?,
                url: URL?,
                notes: String?) {

        self.externalIdentifier = externalIdentifier
        self.calendar = calendar
        self.id = identifier
        self.ekReminderID = ekReminderID
        self.isSubscribed = subscribed
        self.alarm = alarm
        self.isCompleted = completed
        self.title = title
        self.startDate = startDate
        self.dueDate = dueDate
        self.location = location
        self.url = url
        self.notes = notes
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
                lhs.dueDate == rhs.dueDate &&
                lhs.startDate == rhs.startDate  &&
                lhs.externalIdentifier == rhs.externalIdentifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public func isEqualTo(_ item: RCCalendarItem) -> Bool {
        if let comparingTo = item as? RCReminder {
            return self == comparingTo
        }
        return false
    }
}

extension RCReminder {
    public func stopAlarmButtonClicked() {
        self.setAlarmMuted(!self.alarm.isMuted)
    }

    public var timeLabelDisplayString: String {
        return "RCReminder Due at: \(self.alarm.startDate))"
    }
}
