//
//  RCCalendarItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation


public struct RCAlarm: Equatable, CustomStringConvertible, Codable, Loggable {
    
    public let startDate: Date
    public let endDate: Date
    public let isEnabled: Bool
    public let canExpire: Bool
    public let behavior: Behavior
    
    public private(set) var finishedDate: Date?
    
    public var isFinished: Bool {
        didSet {
            if self.isFinished {
                self.finishedDate = Date()
            } else {
                self.finishedDate = nil
            }
        }
    }
    
    public init(startDate: Date,
                endDate: Date,
                enabled: Bool,
                canExpire: Bool,
                behavior: Behavior,
                isFinished: Bool,
                finishedDate: Date?) {

        self.startDate = startDate
        self.endDate = endDate
        self.isEnabled = enabled
        self.canExpire = canExpire
        self.behavior = behavior
        self.isFinished = isFinished
        self.finishedDate = finishedDate
    }

    public static func == (lhs: RCAlarm, rhs: RCAlarm) -> Bool {
        return  lhs.isEnabled == rhs.isEnabled &&
                lhs.canExpire == rhs.canExpire &&
                lhs.startDate == rhs.startDate &&
                lhs.isFinished == rhs.isFinished &&
                lhs.endDate == rhs.endDate &&
                lhs.finishedDate == rhs.finishedDate &&
                lhs.behavior == rhs.behavior
    }
    
    public var description: String {
        return """
        type(of: self): \
        enabled: \(self.isEnabled), \
        canExpire: \(self.canExpire), \
        Fire Behavior: \(self.behavior.description), \
        Start Date: \(self.startDate.shortTimeString), \
        End Date: \(self.endDate.shortTimeString), \
        isFinished: \(self.isFinished), \
        Finished Dates \(self.finishedDate?.description ?? "nil")
        """
    }
    
    public var isHappeningNow: Bool {
        let now = Date()
        return self.startDate.isEqualToOrBeforeDate(now) && self.endDate.isEqualToOrAfterDate(now)
    }

    public var isInThePast: Bool {
        return self.endDate.isBeforeDate(Date())
    }
    
    public var isFiring: Bool {
        return self.isEnabled && !self.isFinished && self.isHappeningNow
    }
    
    public var willFire: Bool {
        return self.isEnabled && !self.isFinished
    }

    public var hasExpired: Bool {
        return self.isInThePast && self.canExpire
    }
    
    public var needsStarting: Bool {
        return self.isEnabled && self.isHappeningNow && !self.isFinished
    }
    
    public var needsFinishing: Bool {
        return self.isEnabled && !self.isFinished && self.isInThePast
    }
    
    public var needsFinishReset: Bool {
        if self.behavior == .fireRepeatedly {
            let midnightYesterday = Date.midnightYesterday
            if  self.isFinished,
                let finishedDate = self.finishedDate,
                finishedDate.isEqualToOrBeforeDate(midnightYesterday),
                self.startDate.isAfterDate(midnightYesterday) {
                return true
            }
        }

        return false
    }

}

extension RCAlarm {
    
    public enum Behavior: Int, CustomStringConvertible, Codable {
        
        case fireOnce               = 0
        case fireRepeatedly         = 1
        
        public var description: String {
            switch self {
            case .fireOnce:
                return "fireOnce"
            case .fireRepeatedly:
                return "fireRepeatedly"
            }
        }
    }
    
}
