//
//  RCEvent.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit
import RoosterCore.Private

public struct RCEvent: Identifiable, Hashable, RCCalendarItem, Equatable {
    
    public let calendar: RCCalendar
    public let id: String
    public var isSubscribed: Bool
    public var alarm: RCAlarm {
        didSet {
            self.logger.log("alarm did update: ")
        }
    }
    public let ekEvent: EKEvent

    /// MARK - EKEvent wrappers
    
    public var startDate: Date {
        return self.ekEvent.startDate
    }
    
    public var endDate: Date {
        return self.ekEvent.endDate
    }
    
    public var title: String {
        return self.ekEvent.title
    }
    
    public var ekEventID: String {
        return self.ekEvent.calendarItemIdentifier
    }
    
    public var organizer: RCParticipant? {
        
        guard self.ekEvent.organizer != nil else {
            return nil
        }
        
        return RCParticipant(ekParticipant: self.ekEvent.organizer!)
    }
    
    public var location: String? {
        return self.ekEvent.location
    }
    
    public var url: URL? {
        return self.ekEvent.url
    }
    
    public var notes: String? {
        return self.ekEvent.notes
    }
    
    public var externalIdentifier: String {
        return self.ekEvent.calendarItemExternalIdentifier
    }
    
    public var isAllDay: Bool {
        return self.ekEvent.isAllDay
    }
    
    public var isDetached: Bool {
        return self.ekEvent.isDetached
    }

    public var occurenceDate: Date? {
        return self.ekEvent.nullableOccurenceDate
    }
    
    public let isRecurring: Bool
    
    public var status: Status {
        return Status(rawValue: self.ekEvent.status.rawValue) ?? .none
    }
    
    public var availability: Availability {
        return Availability(rawValue:  self.ekEvent.availability.rawValue) ?? .notSupported
    }
    
    // TODO: show special birthday banners?
    public var birthdayContactIdentifier: String? {
        return self.ekEvent.birthdayContactIdentifier
    }

    public init(withIdentifier identifier: String,
                ekEvent: EKEvent,
                calendar: RCCalendar,
                subscribed: Bool,
                alarm: RCAlarm) {
    
        let isRecurring = ekEvent.nullableOccurenceDate != nil
        self.ekEvent = ekEvent
        self.id = identifier
        self.calendar = calendar
        self.isSubscribed = subscribed
        self.isRecurring = isRecurring
        self.alarm = RCAlarm(startDate: ekEvent.startDate,
                             endDate: ekEvent.endDate,
                             enabled: alarm.isEnabled,
                             canExpire: true,
                             behavior: isRecurring ? .fireRepeatedly : .fireOnce,
                             isFinished: alarm.isFinished,
                             finishedDate: alarm.finishedDate)
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        calendar: \(self.calendar.description) \
        title: \(self.title), \
        startTime: \(self.startDate), \
        endTime: \(self.endDate), \
        alarm: \(self.alarm)"
        """
    }
    
    public static func == (lhs: RCEvent, rhs: RCEvent) -> Bool {
        return  lhs.id == rhs.id &&
                lhs.calendar.id == rhs.calendar.id &&
                lhs.title == rhs.title &&
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.alarm == rhs.alarm &&
                lhs.startDate == rhs.startDate &&
                lhs.endDate == rhs.endDate &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.organizer == rhs.organizer &&
                lhs.externalIdentifier == rhs.externalIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension RCEvent {
    
    public var timeLabelDisplayString: String {
        let startTime = self.startDate.shortTimeString
        let endTime = self.endDate.shortTimeString

        return "\(startTime) - \(endTime)"
    }
}


extension RCEvent {

    public func update(withSavedState state: CalendarItemStorageRecord) -> RCEvent {
        return RCEvent(withIdentifier: self.id,
                       ekEvent: self.ekEvent,
                       calendar: self.calendar,
                       subscribed: state.isSubscribed,
                       alarm: state.alarm)

    }

    public init(withEvent EKEvent: EKEvent,
                calendar: RCCalendar,
                savedState: CalendarItemStorageRecord) {
        
        self.init(withIdentifier: EKEvent.uniqueID,
                  ekEvent: EKEvent,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: savedState.alarm)
    }
}

extension RCEvent {
    
    public enum RecurrenceFrequency : Int, CustomStringConvertible, Codable {
        case daily              = 0
        case weekly             = 1
        case monthly            = 2
        case yearly             = 3

        public var description: String {
            switch(self) {
            case .daily:
                return "daily"
            case .weekly:
                return "weekly"
            case .monthly:
                return "monthly"
            case .yearly:
                return "yearly"
            }
        }
    }

    public enum Availability : Int, CustomStringConvertible, Codable {
        case notSupported = -1
        case busy = 0
        case free = 1
        case tentative = 2
        case unavailable = 3

        public var description: String {
            switch(self) {
            case .notSupported:
                return "notSupported"
            case .busy:
                return "busy"
            case .free:
                return "free"
            case .tentative:
                return "tentative"
            case .unavailable:
                return "unavailable"
            }
        }
    }

    public enum Status : Int, CustomStringConvertible, Codable {
        case none = 0
        case confirmed = 1
        case tentative = 2
        case canceled = 3

        public var description: String {
            switch(self) {
            case .none:
                return "none"
            case .confirmed:
                return "confirmed"
            case .tentative:
                return "tentative"
            case .canceled:
                return "canceled"
            }
        }
    }
    
    
}

