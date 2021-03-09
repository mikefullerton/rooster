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
    
    // MARK: - read only properties
    
    public let calendar: RCCalendar
    
    public let id: String
    
    public let ekEvent: EKEvent

    public var hasChanges: Bool {
        return  self.ekEvent.startDate != self.startDate ||
                self.ekEvent.endDate != self.endDate ||
                self.ekEvent.title != self.title ||
                self.ekEvent.location != self.location ||
                self.ekEvent.notes != self.notes ||
                self.ekEvent.participationStatus_ != EKParticipantStatus(rawValue: self.participationStatus.rawValue) ||
                self.ekEvent.availability != EKEventAvailability(rawValue: self.availability.rawValue) ||
                self.ekEvent.isAllDay != self.isAllDay
    }

    public var organizer: RCParticipant?

    public let externalIdentifier: String
    
    public let isDetached: Bool

    public let occurenceDate: Date?
    
    public let isRecurring: Bool

    public var hasParticipants: Bool
    
    public var participants: [RCParticipant]
    
    public var typeDisplayName: String {
        return "Event"
    }
    
    public var length: TimeInterval {
        return self.endDate.difference(fromDate: self.startDate)
    }
    
    public let allowsParticipationStatusModifications: Bool
    
    public var lastModifiedDate: Date?
    
    public let timeZone: TimeZone?
    
    public let creationDate: Date?
    
    // TODO: show special birthday banners?
    public let birthdayContactIdentifier: String?
    
    public let status: EventStatus
    
    public var timeLabelDisplayString: String {
        let startTime = self.startDate.shortTimeString
        let endTime = self.startDate.shortTimeString

        return "\(startTime) - \(endTime)"
    }
    
    // MARK: - modifiable rooster properties
    
    public var isSubscribed: Bool
    
    public var alarm: RCAlarm

    // MARK: - modifiable eventKit properties
    
    public var startDate: Date
    
    public var endDate: Date
    
    public var title: String
    
    public var location: String?
    
    public var url: URL?
    
    public var notes: String?
    
    public var participationStatus: ParticipantStatus
    
    public var availability: EventAvailability

    public var isAllDay: Bool
    
    public var isMultiDay: Bool {
        if let days = Date.daysBetween(lhs: self.startDate, rhs: self.endDate) {
            return days > 1
        }
        
        return false
    }
    
    public func occursBetween(startDate: Date, endDate: Date) -> Bool {
        return Date.range(self.startDate...self.endDate, intersectsRange: startDate...endDate)
    }
    
    public init(ekEvent: EKEvent,
                calendar: RCCalendar,
                subscribed: Bool,
                alarm: RCAlarm) {
    
        // readonly
        self.calendar = calendar
        self.id = ekEvent.uniqueID
        self.ekEvent = ekEvent
        self.organizer = ekEvent.organizer != nil ? RCParticipant(ekParticipant: self.ekEvent.organizer!) : nil
        self.externalIdentifier = ekEvent.calendarItemExternalIdentifier
        self.isDetached = ekEvent.isDetached
        self.occurenceDate = ekEvent.nullableOccurenceDate
        self.isRecurring = ekEvent.hasRecurrenceRules
        self.hasParticipants = ekEvent.hasAttendees
        self.participants = ekEvent.attendees?.map { RCParticipant(ekParticipant: $0) } ?? []
        self.allowsParticipationStatusModifications = ekEvent.allowsParticipationStatusModifications_
        self.lastModifiedDate = ekEvent.lastModifiedDate
        self.timeZone = ekEvent.timeZone
        self.creationDate = ekEvent.creationDate
        self.birthdayContactIdentifier = self.ekEvent.birthdayContactIdentifier
        
        // modifiable
        self.isSubscribed = subscribed
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.title = ekEvent.title
        self.location = ekEvent.location
        self.url = ekEvent.url
        self.notes = ekEvent.notes
        self.status = EventStatus(rawValue: self.ekEvent.status.rawValue) ?? .none
        self.participationStatus = ParticipantStatus(rawValue: ekEvent.participationStatus_.rawValue) ?? .unknown
        self.availability = EventAvailability(rawValue: ekEvent.availability.rawValue) ?? .notSupported
        self.isAllDay = ekEvent.isAllDay
        
        if ekEvent.isAllDay {
            self.alarm = RCAlarm(startDate: Date.midnightToday.addSeconds(1),
                                 endDate:  Date.midnightToday.addHours(1),
                                 enabled: false,
                                 canExpire: true,
                                 finishedDate: alarm.finishedDate)
        } else {
            self.alarm = RCAlarm(startDate: ekEvent.startDate,
                                 endDate: ekEvent.endDate,
                                 enabled: true,
                                 canExpire: true,
                                 finishedDate: alarm.finishedDate)
        }
    }

    public init(ekEvent: EKEvent,
                calendar: RCCalendar,
                subscribed: Bool) {
    
        let alarm = RCAlarm(startDate: ekEvent.startDate,
                             endDate: ekEvent.endDate,
                             enabled: subscribed,
                             canExpire: true,
                             finishedDate: nil)
        
        self.init(ekEvent: ekEvent,
                  calendar: calendar,
                  subscribed: subscribed,
                  alarm: alarm)
    }
    
    public var description: String {
        return """
        \(type(of:self)): \
        calendar: \(self.calendar.description) \
        title: \(self.title), \
        startDate: \(self.startDate.shortDateAndLongTimeString), \
        endDate: \(self.endDate.shortDateAndLongTimeString), \
        alarm : \(self.alarm.description)"
        """
    }
    
    public static func == (lhs: RCEvent, rhs: RCEvent) -> Bool {
        return  lhs.calendar.id == rhs.calendar.id &&
                lhs.id == rhs.id &&
                lhs.organizer == rhs.organizer &&
                lhs.externalIdentifier == rhs.externalIdentifier &&
                lhs.occurenceDate == rhs.occurenceDate &&
                lhs.participants == rhs.participants &&
                lhs.lastModifiedDate == rhs.lastModifiedDate &&
                lhs.timeZone == rhs.timeZone &&
                lhs.creationDate == rhs.creationDate &&
                
                // modifiable
                lhs.isSubscribed == rhs.isSubscribed &&
                lhs.startDate == rhs.startDate &&
                lhs.endDate == rhs.endDate &&
                lhs.title == rhs.title &&
                lhs.location == rhs.location &&
                lhs.url == rhs.url &&
                lhs.notes == rhs.notes &&
                lhs.status == rhs.status &&
                lhs.participationStatus == rhs.participationStatus &&
                lhs.availability == rhs.availability &&
                lhs.isAllDay == rhs.isAllDay &&
                lhs.alarm == rhs.alarm
                
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension RCEvent {

    public func update(withSavedState state: EventStorageRecord) -> RCEvent {
        return RCEvent(ekEvent: self.ekEvent,
                       calendar: self.calendar,
                       subscribed: state.isSubscribed,
                       alarm: state.alarm)

    }

    public init(withEvent EKEvent: EKEvent,
                calendar: RCCalendar,
                savedState: EventStorageRecord) {
        
        self.init(ekEvent: EKEvent,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: savedState.alarm)
    }
}

public enum EventRecurrenceFrequency : Int, CustomStringConvertible, Codable {
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

public enum EventAvailability : Int, CustomStringConvertible, Codable {
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

public enum EventStatus : Int, CustomStringConvertible, Codable {
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


