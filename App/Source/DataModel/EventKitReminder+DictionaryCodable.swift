//
//  EventKitReminder+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension EventKitReminder {

    // represents the small subset of data we actually store for a Reminder
    struct SavedState: DictionaryCodable {

        enum CodingKeys: String, CodingKey {
            case subscribed = "subscribed"
            case alarm = "alarm"
        }
        
        let isSubscribed: Bool
        let alarmState: EventKitAlarm.SavedState
        
        init(isSubscribed: Bool, alarmState: EventKitAlarm.SavedState) {
            self.isSubscribed = isSubscribed
            self.alarmState = alarmState
        }

        init(withReminder reminder: EventKitReminder) {
            self.isSubscribed = reminder.isSubscribed
            self.alarmState = EventKitAlarm.SavedState(withAlarm: reminder.alarm)
        }
        
        init?(withDictionary dictionary: [AnyHashable : Any]) {
            guard let subscribedBool = dictionary[CodingKeys.subscribed.rawValue] as? Bool  else {
                return nil
            }

            guard let alarmStateDictionary = dictionary[CodingKeys.alarm.rawValue] as? [AnyHashable: Any]  else {
                return nil
            }
            
            guard let alarmState = EventKitAlarm.SavedState(withDictionary: alarmStateDictionary) else {
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

    func update(withSavedState state: SavedState) -> EventKitReminder {
        return EventKitReminder(withReminder: self.EKReminder,
                                calendar: self.calendar,
                                subscribed: state.isSubscribed,
                                alarm: self.alarm)
    }
    
    init(withReminder EKReminder: EKReminder,
         calendar: EventKitCalendar,
         startDate: Date,
         endDate: Date?,
         savedState: SavedState) {
        
        let alarm = EventKitAlarm(withSavedState: savedState.alarmState,
                                 startDate: startDate,
                                 endDate: endDate)
        
        self.init(withReminder: EKReminder,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: alarm)
    }
}
