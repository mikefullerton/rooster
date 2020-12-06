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
        case finished = "finishe"
    }

    let state: State
    let date: Date
    let isEnabled: Bool
    let snoozeInterval: TimeInterval
    
    init(withState state: State,
         date: Date,
         isEnabled: Bool,
         snoozeInterval: TimeInterval) {
        self.state = state
        self.date = snoozeInterval > 0 ? date.addingTimeInterval(snoozeInterval) : date
        self.isEnabled = isEnabled
        self.snoozeInterval = snoozeInterval
    }

    static func == (lhs: EventKitAlarm, rhs: EventKitAlarm) -> Bool {
        return  lhs.state == rhs.state &&
                lhs.date == rhs.date &&
                lhs.isEnabled == rhs.isEnabled
    }
    
    func updatedAlarm(_ state: State) -> EventKitAlarm {
        return EventKitAlarm(withState: state,
                             date: self.date,
                             isEnabled: self.isEnabled,
                             snoozeInterval: self.snoozeInterval)
    }

    func snoozeAlarm(_ snoozeInterval: TimeInterval) -> EventKitAlarm {
        return EventKitAlarm(withState: .neverFired,
                             date: self.date,
                             isEnabled: self.isEnabled,
                             snoozeInterval: self.snoozeInterval + snoozeInterval)
    }

    var description: String {
        return ("EventKitAlarm: Alarm date: \(String(describing: self.date)), state: \(self.state), isEnabled: \(self.isEnabled)")
    }
    
    var isFiring: Bool {
        return self.state == .firing
    }
    
    var fireDate: Date {
        if self.snoozeInterval > 0 {
            return self.date.addingTimeInterval(self.snoozeInterval)
        }
        
        return self.date
    }
    
    var shouldFire: Bool {
        if self.isEnabled {
            return self.fireDate.isBeforeDate(Date())
        }
        
        return false
    }
    
}


