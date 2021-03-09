//
//  RCCalendarItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation


public struct RCAlarm: Equatable, CustomStringConvertible, Codable, Loggable {
    
    public var startDate: Date?
    public var endDate: Date?
    public var isEnabled: Bool
    public var canExpire: Bool
    
    public private(set) var finishedDate: Date?
    
    public var isFinished: Bool {
        get {
            return self.finishedDate != nil
        }
        set {
            if self.isFinished != newValue {
                if newValue {
                    self.finishedDate = Date()
                } else {
                    self.finishedDate = nil
                }
            }
        }
    }
    
    public init(startDate: Date?,
                endDate: Date?,
                enabled: Bool,
                canExpire: Bool,
                finishedDate: Date?) {

        self.startDate = startDate
        self.endDate = endDate
        self.isEnabled = enabled
        self.canExpire = canExpire
        self.finishedDate = finishedDate
    }

    public static func == (lhs: RCAlarm, rhs: RCAlarm) -> Bool {
        return  lhs.isEnabled == rhs.isEnabled &&
                lhs.canExpire == rhs.canExpire &&
                lhs.startDate == rhs.startDate &&
                lhs.endDate == rhs.endDate &&
                lhs.finishedDate == rhs.finishedDate
    }
    
    public var description: String {
        return """
        type(of: self): \
        enabled: \(self.isEnabled), \
        canExpire: \(self.canExpire), \
        Start Date: \(self.startDate?.shortTimeString ?? "nil"), \
        End Date: \(self.endDate?.shortTimeString ?? "nil"), \
        isFinished: \(self.isFinished), \
        Finished Dates \(self.finishedDate?.description ?? "nil")
        """
    }
    
    public var isHappeningNow: Bool {
        
        if let startDate = self.startDate,
        let endDate = self.endDate {
            let now = Date()
            return startDate.isEqualToOrBeforeDate(now) && endDate.isEqualToOrAfterDate(now)
        }
        
        return false
    }

    public var isInThePast: Bool {
        return self.endDate?.isBeforeDate(Date()) ?? false
    }
    
    public var isInTheFuture: Bool {
        return self.startDate?.isAfterDate(Date()) ?? false
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
    
    public var hasDates: Bool {
        return self.startDate != nil && self.endDate != nil
    }
}
