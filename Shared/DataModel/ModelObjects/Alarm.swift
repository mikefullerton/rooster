//
//  CalendarItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation


struct Alarm: Equatable, CustomStringConvertible {
    
    enum State: String {
        case none = "none"
        case willFire = "willFire"
        case firing = "firing"
        case hasExpired = "hasExpired"
    }

    let originalStartDate: Date
    let originalEndDate: Date
    
    let snoozedStartDate: Date
    let snoozedEndDate: Date

    let startDate: Date
    let endDate: Date
    
    private(set) var lastState: State
    
    // modifiable
    var isEnabled: Bool
    var mutedDate: Date?
    var snoozeInterval: TimeInterval
    
    init(startDate originalStartDate: Date,
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

    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        return  lhs.state == rhs.state &&
                lhs.originalStartDate == rhs.originalStartDate &&
                lhs.originalEndDate == rhs.originalEndDate &&
                lhs.snoozeInterval == rhs.snoozeInterval &&
                lhs.isEnabled == rhs.isEnabled &&
                lhs.mutedDate == rhs.mutedDate
    }
    
    var description: String {
        var formatter = StringFormatter(withTitle: "Alarm")
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
    
    mutating func updateState() -> Bool {
        let newState = self.state
        if newState != self.lastState {
            self.lastState = newState
            return true
        }
        
        return false
    }
    
    var isMuted: Bool {
        return self.mutedDate != nil
    }
    
    var isFiring: Bool {
        return self.state == .firing && self.isEnabled && !self.isMuted
    }
    
    var willFire: Bool {
        return self.state == .willFire && self.isEnabled && !self.isMuted
    }

    var hasExpired: Bool {
        return self.state == .hasExpired
    }
}


