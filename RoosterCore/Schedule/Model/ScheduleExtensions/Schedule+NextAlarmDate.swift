//
//  ScheduleController+NextAlarmDate.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/30/21.
//

import Foundation

extension Schedule {
    public func nextAlarmDate(forItems items: [ScheduleItem]) -> Date? {
        var nextDate: Date?

        for item in items {
            if let alarm = item.alarm,
                alarm.willFire &&
                (nextDate == nil || alarm.dateRange.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.dateRange.startDate
            }
        }

        return nextDate
    }

    public var nextAlarmDate: Date? {
        self.nextAlarmDate(forItems: self.items)
    }

    private func nextAlarmDateForSchedulingTimer(forItems items: [ScheduleItem]) -> Date? {
        let now = Date()
        var nextDate: Date?

        for item in items {
            if  let alarm = item.alarm {
                let startDate = alarm.dateRange.startDate
                let endDate = alarm.dateRange.endDate

                if endDate.isAfterDate(now),
                   (nextDate == nil || endDate.isBeforeDate(nextDate!)) {
                    nextDate = endDate
                }

                if startDate.isAfterDate(now),
                   (nextDate == nil || startDate.isBeforeDate(nextDate!)) {
                    nextDate = startDate
                }
            }
        }

        return nextDate
    }

    public var nextAlarmDateForSchedulingTimer: Date? {
        self.nextAlarmDateForSchedulingTimer(forItems: self.items)
    }
}
