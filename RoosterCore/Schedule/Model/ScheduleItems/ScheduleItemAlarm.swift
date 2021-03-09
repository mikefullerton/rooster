//
//  EventKitCalendarItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

public struct ScheduleItemAlarm: Equatable, CustomStringConvertible, Loggable {
    public let dateRange: DateRange

    public private(set) var finishedDate: Date?

    public var isFinished: Bool {
        get {
            self.finishedDate != nil
        }
        set {
            if newValue {
                self.finishedDate = Date()
            } else {
                self.finishedDate = nil
            }
        }
    }

    public init(dateRange: DateRange,
                finishedDate: Date?) {
        self.dateRange = dateRange
        self.finishedDate = finishedDate
    }

    public var description: String {
        """
        \(type(of: self)): \
        date range: \(self.dateRange.description), \
        isFinished: \(self.isFinished), \
        Finished Date: \(self.finishedDate?.description ?? "nil")
        """
    }

    public var isFiring: Bool {
        !self.isFinished && self.dateRange.isHappeningNow
    }

    public var willFire: Bool {
        !self.isFinished
    }

    public var needsStarting: Bool {
        self.dateRange.isHappeningNow && !self.isFinished
    }

    public var needsFinishing: Bool {
        !self.isFinished && self.dateRange.isInThePast
    }

    public static func == (lhs: ScheduleItemAlarm, rhs: ScheduleItemAlarm) -> Bool {
        lhs.dateRange == rhs.dateRange &&
        lhs.finishedDate == rhs.finishedDate
    }
}
