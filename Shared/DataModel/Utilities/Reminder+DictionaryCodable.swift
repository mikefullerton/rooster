//
//  Reminder+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension Reminder {

    // represents the small subset of data we actually store for a Reminder
    struct SavedState: DictionaryCodable {

        enum CodingKeys: String, CodingKey {
            case subscribed = "subscribed"
            case alarm = "alarm"
        }
        
        let isSubscribed: Bool
        let alarmState: Alarm.SavedState
        
        init(isSubscribed: Bool, alarmState: Alarm.SavedState) {
            self.isSubscribed = isSubscribed
            self.alarmState = alarmState
        }

        init(withReminder reminder: Reminder) {
            self.isSubscribed = reminder.isSubscribed
            self.alarmState = Alarm.SavedState(withAlarm: reminder.alarm)
        }
        
        init?(withDictionary dictionary: [AnyHashable : Any]) {
            guard let subscribedBool = dictionary[CodingKeys.subscribed.rawValue] as? Bool  else {
                return nil
            }

            guard let alarmStateDictionary = dictionary[CodingKeys.alarm.rawValue] as? [AnyHashable: Any]  else {
                return nil
            }
            
            guard let alarmState = Alarm.SavedState(withDictionary: alarmStateDictionary) else {
                return nil
            }

            self.alarmState = alarmState
            self.isSubscribed = subscribedBool
        }

        var dictionaryRepresentation: [AnyHashable : Any] {
            var dictionary: [AnyHashable : Any] = [:]
            dictionary[CodingKeys.alarm.rawValue] = self.alarmState.dictionaryRepresentation
            dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
            return dictionary
        }
    }

    func update(withSavedState savedState: SavedState) -> Reminder {

        let alarm = Alarm(withSavedState: savedState.alarmState,
                                  startDate: self.dueDate,
                                  endDate: self.dueDate.addingTimeInterval(60 * 60 * 15))

        return Reminder(withIdentifier: self.id,
                                ekReminderID:self.ekReminderID,
                                externalIdentifier: self.externalIdentifier,
                                calendar: self.calendar,
                                subscribed: savedState.isSubscribed,
                                completed: self.isCompleted,
                                alarm: alarm,
                                startDate: self.startDate,
                                dueDate: self.dueDate,
                                title: self.title,
                                location: self.location,
                                url: self.url,
                                notes: self.notes)

    }
    
    init(withReminder EKReminder: EKReminder,
         calendar: Calendar,
         startDate: Date,
         endDate: Date,
         savedState: SavedState) {
        
        let alarm = Alarm(withSavedState: savedState.alarmState,
                                 startDate: startDate,
                                 endDate: endDate)
        
        self.init(withIdentifier: EKReminder.uniqueID,
                  ekReminderID: EKReminder.calendarItemIdentifier,
                  externalIdentifier: EKReminder.calendarItemExternalIdentifier,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  completed: EKReminder.isCompleted,
                  alarm: alarm,
                  startDate: EKReminder.startDateComponents?.date ?? Date.distantFuture,
                  dueDate: EKReminder.dueDateComponents?.date ?? Date.distantFuture,
                  title: EKReminder.title,
                  location: EKReminder.location,
                  url: EKReminder.url,
                  notes: EKReminder.notes)

    }

}
