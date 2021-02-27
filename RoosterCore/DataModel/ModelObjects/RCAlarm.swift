//
//  RCCalendarItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation


public struct RCAlarm: Equatable, CustomStringConvertible {
    
    enum State: String {
        case none = "none"
        case willFire = "willFire"
        case firing = "firing"
        case hasExpired = "hasExpired"
    }

    public let originalStartDate: Date
    public let originalEndDate: Date
    
    public let snoozedStartDate: Date
    public let snoozedEndDate: Date

    public let startDate: Date
    public let endDate: Date
    
    private(set) var lastState: State
    
    // modifiable
    public var isEnabled: Bool
    public var mutedDate: Date?
    public var snoozeInterval: TimeInterval
    
    public init(startDate originalStartDate: Date,
         endDate originalEndDate: Date,
         isEnabled: Bool,
         mutedDate: Date?,
         snoozeInterval: TimeInterval) {

        let snoozedStartDate = snoozeInterval > 0 ? originalStartDate.addingTimeInterval(snoozeInterval) : originalStartDate
        let snoozedEndDate = snoozeInterval > 0 ? originalEndDate.addingTimeInterval(snoozeInterval) : originalEndDate

        self.isEnabled = isEnabled
        self.originalStartDate = originalStartDate
        self.originalEndDate = originalEndDate
        self.snoozeInterval = snoozeInterval
        self.snoozedStartDate = snoozedStartDate
        self.snoozedEndDate = snoozedEndDate
        self.startDate = snoozedStartDate
        self.endDate = snoozedEndDate
        self.mutedDate = mutedDate
        self.lastState = .none
    }

    public static func == (lhs: RCAlarm, rhs: RCAlarm) -> Bool {
        return  lhs.state == rhs.state &&
                lhs.originalStartDate == rhs.originalStartDate &&
                lhs.originalEndDate == rhs.originalEndDate &&
                lhs.snoozeInterval == rhs.snoozeInterval &&
                lhs.isEnabled == rhs.isEnabled &&
                lhs.mutedDate == rhs.mutedDate
    }
    
    public var description: String {
        var formatter = StringFormatter(withTitle: "RCAlarm")
        formatter.append("State", self.state)
        formatter.append("Start Date", self.startDate.shortTimeString)
        formatter.append("End Date", self.endDate.shortTimeString)
        formatter.append("Original Start Date", self.originalStartDate.shortTimeString)
        formatter.append("Original End Date", self.originalEndDate.shortTimeString)
        formatter.append("Snoozed Start Date", self.snoozedStartDate.shortTimeString)
        formatter.append("Snoozed End Date", self.snoozedEndDate.shortTimeString)
        formatter.append("Muted Date", self.mutedDate?.shortTimeString ?? "nil")
        formatter.append("isEnabled", self.isEnabled)
        return formatter.string
    }
    
    private var state: State {
        let now = Date()
        
        if self.endDate.isBeforeDate(now) {
            return .hasExpired
        }
        
        if self.startDate.isEqualToOrBeforeDate(now) {
            return .firing
        }
        
        return .willFire
    }
    
    public mutating func updateState() -> Bool {
        let newState = self.state
        if newState != self.lastState {
            self.lastState = newState
            return true
        }
        
        return false
    }
    
    public var isMuted: Bool {
        return self.mutedDate != nil
    }
    
    public var isFiring: Bool {
        return self.state == .firing && self.isEnabled && !self.isMuted
    }
    
    public var willFire: Bool {
        return self.state == .willFire && self.isEnabled && !self.isMuted
    }

    public var hasExpired: Bool {
        return self.state == .hasExpired
    }
}


