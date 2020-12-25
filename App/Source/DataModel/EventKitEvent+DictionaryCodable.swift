//
//  EventKitEvent+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension EventKitEvent {

    // represents the small subset of data we actually store for an Event
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
        
        init(withEvent event: EventKitEvent) {
            self.isSubscribed = event.isSubscribed
            self.alarmState = EventKitAlarm.SavedState(withAlarm: event.alarm)
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
            dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
            dictionary[CodingKeys.alarm.rawValue] = self.alarmState.dictionaryRepresentation
            return dictionary
        }
    }
    
    func update(withSavedState state: SavedState) -> EventKitEvent {
        return EventKitEvent(withEvent: self.EKEvent,
                             calendar: self.calendar,
                             subscribed: state.isSubscribed,
                             alarm: EventKitAlarm(withSavedState: state.alarmState,
                                                  startDate: self.startDate,
                                                  endDate: self.endDate))
    }

    init(withEvent EKEvent: EKEvent,
         calendar: EventKitCalendar,
         savedState: SavedState) {
        
        let alarm = EventKitAlarm(withSavedState: savedState.alarmState,
                                  startDate: EKEvent.startDate,
                                  endDate: EKEvent.endDate)
        
        self.init(withEvent: EKEvent,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: alarm)
    }
}


