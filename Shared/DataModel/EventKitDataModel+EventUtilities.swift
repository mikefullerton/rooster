//
//  EventKitDataModel+EventUtilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

extension EventKitDataModel {

    private func nextActionableAlarmDate(forItems items: [Alarmable]) -> Date? {
        let now = Date()
        var nextDate = now.tomorrow
        
        for item in items {

            let alarm = item.alarm
            
            if let endDate = alarm.endDate,
               endDate.isAfterDate(now),
               (nextDate == nil || endDate.isBeforeDate(nextDate!)) {
                nextDate = endDate
            }

            if alarm.startDate.isAfterDate(now),
               (nextDate == nil || alarm.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    var nextActionableAlarmDate: Date? {
        let nextEventDate = self.nextActionableAlarmDate(forItems: self.events)
        let nextReminderDate = self.nextActionableAlarmDate(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
    
    private func nextAlarmDate(forItems items: [Alarmable]) -> Date? {
        let now = Date()
        var nextDate = now.tomorrow
        
        for item in items {

            let alarm = item.alarm
            
            if alarm.startDate.isAfterDate(now),
               (nextDate == nil || alarm.startDate.isBeforeDate(nextDate!)) {
                nextDate = alarm.startDate
            }
        }

        return nextDate
    }
    
    var nextAlarmDate: Date? {
        let nextEventDate = self.nextAlarmDate(forItems: self.events)
        let nextReminderDate = self.nextAlarmDate(forItems: self.reminders)
        
        if nextEventDate != nil && nextReminderDate != nil {
            return nextEventDate!.isBeforeDate(nextReminderDate!) ? nextEventDate : nextReminderDate
        }
        
        return nextEventDate != nil ? nextEventDate : nextReminderDate
    }
    
}

extension Date {
    
    var tomorrow: Date? {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
}
