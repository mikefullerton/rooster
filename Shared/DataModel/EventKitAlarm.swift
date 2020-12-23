//
//  Alarmable.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation


struct EventKitAlarm: Equatable, CustomStringConvertible {
    
    enum State: String {
        case neverFired = "neverFired"
        case firing = "firing"
        case finished = "finished"
        case willNeverFire = "never"
    }

    let state: State
    
    let originalStartDate: Date
    let originalEndDate: Date?
    
    let snoozedStartDate: Date?
    let snoozedEndDate: Date?

    let startDate: Date
    let endDate: Date?
    
    let isEnabled: Bool
    let snoozeInterval: TimeInterval
    
    init(withState state: State,
         startDate originalStartDate: Date,
         endDate originalEndDate: Date?,
         isEnabled: Bool,
         snoozeInterval: TimeInterval) {

        let snoozedStartDate = snoozeInterval > 0 ? originalStartDate.addingTimeInterval(snoozeInterval) : nil
        let snoozedEndDate = snoozeInterval > 0 && originalEndDate != nil ? originalEndDate!.addingTimeInterval(snoozeInterval) : nil

        self.isEnabled = isEnabled
        self.state = state
        self.originalStartDate = originalStartDate
        self.originalEndDate = originalEndDate
        self.snoozeInterval = snoozeInterval
        self.snoozedStartDate = snoozedStartDate
        self.snoozedEndDate = snoozedEndDate
        self.startDate = snoozedStartDate != nil ? snoozedStartDate! : originalStartDate
        self.endDate = snoozedEndDate != nil ? snoozedEndDate : originalEndDate
    }

    static func == (lhs: EventKitAlarm, rhs: EventKitAlarm) -> Bool {
        return  lhs.state == rhs.state &&
                lhs.originalStartDate == rhs.originalStartDate &&
                lhs.originalEndDate == rhs.originalEndDate &&
                lhs.snoozeInterval == rhs.snoozeInterval &&
                lhs.isEnabled == rhs.isEnabled
    }
    
    func updatedAlarm(_ state: State) -> EventKitAlarm {
        return EventKitAlarm(withState: state,
                             startDate: self.originalStartDate,
                             endDate: self.originalEndDate,
                             isEnabled: self.isEnabled,
                             snoozeInterval: self.snoozeInterval)
    }

    func snoozeAlarm(_ snoozeInterval: TimeInterval) -> EventKitAlarm {
        return EventKitAlarm(withState: .neverFired,
                             startDate: self.originalStartDate,
                             endDate: self.originalEndDate,
                             isEnabled: self.isEnabled,
                             snoozeInterval: self.snoozeInterval + snoozeInterval)
    }

    var description: String {
        var formatter = StringFormatter(withTitle: "EventKitAlarm")
        formatter.append("State", self.state)
        formatter.append("Start Date", self.startDate.shortDateString)
        formatter.append("End Date", self.endDate?.shortDateString)
        formatter.append("Original Start Date", self.originalStartDate.shortDateString)
        formatter.append("Original End Date", self.originalEndDate?.shortDateString)
        formatter.append("Snoozed Start Date", self.snoozedStartDate?.shortDateString)
        formatter.append("Snoozed End Date", self.snoozedEndDate?.shortDateString)
        formatter.append("isEnabled", self.isEnabled)
        return formatter.string
    }
    
    var isFiring: Bool {
        return self.state == .firing
    }

    var isHappeningNow: Bool {
        let now = Date()
        return (self.startDate.isBeforeDate(now) && (self.endDate == nil || self.endDate!.isAfterDate(now)))
    }
    
    var willFireInTheFuture: Bool {
        return self.startDate.isAfterDate(Date())
    }
}


