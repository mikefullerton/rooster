//
//  RCReminder+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension RCReminder {

    // represents the small subset of data we actually store for a RCReminder
    public struct SavedState: DictionaryCodable {

        enum CodingKeys: String, CodingKey {
            case subscribed = "subscribed"
            case alarm = "alarm"
        }
        
        public let isSubscribed: Bool
        public let alarmState: RCAlarm.SavedState
        
        public init(isSubscribed: Bool, alarmState: RCAlarm.SavedState) {
            self.isSubscribed = isSubscribed
            self.alarmState = alarmState
        }

        public init(withReminder reminder: RCReminder) {
            self.isSubscribed = reminder.isSubscribed
            self.alarmState = RCAlarm.SavedState(withAlarm: reminder.alarm)
        }
        
        public init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {
            if let dictionary = dictionaryOrNil {
           
                guard let subscribedBool = dictionary[CodingKeys.subscribed.rawValue] as? Bool  else {
                    return nil
                }

                guard let alarmStateDictionary = dictionary[CodingKeys.alarm.rawValue] as? [AnyHashable: Any]  else {
                    return nil
                }
                
                guard let alarmState = RCAlarm.SavedState(withDictionary: alarmStateDictionary) else {
                    return nil
                }

                self.alarmState = alarmState
                self.isSubscribed = subscribedBool
            } else {
                return nil
            }
        }

        public var dictionaryRepresentation: [AnyHashable : Any] {
            var dictionary: [AnyHashable : Any] = [:]
            dictionary[CodingKeys.alarm.rawValue] = self.alarmState.dictionaryRepresentation
            dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
            return dictionary
        }
    }

    public func update(withSavedState savedState: SavedState) -> RCReminder {

        let alarm = RCAlarm(withSavedState: savedState.alarmState,
                                  startDate: self.dueDate,
                                  endDate: self.dueDate.addingTimeInterval(60 * 60 * 15))

        return RCReminder(withIdentifier: self.id,
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
    
    public init(withReminder EKReminder: EKReminder,
                calendar: RCCalendar,
                startDate: Date,
                endDate: Date,
                savedState: SavedState) {
        
        let alarm = RCAlarm(withSavedState: savedState.alarmState,
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
