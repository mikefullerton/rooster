//
//  Event+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension Event {

    // represents the small subset of data we actually store for an Event
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
        
        init(withEvent event: Event) {
            self.isSubscribed = event.isSubscribed
            self.alarmState = Alarm.SavedState(withAlarm: event.alarm)
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
            dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
            dictionary[CodingKeys.alarm.rawValue] = self.alarmState.dictionaryRepresentation
            return dictionary
        }
    }
    
    func update(withSavedState state: SavedState) -> Event {
        
        let alarm = Alarm(withSavedState: state.alarmState,
                                  startDate: self.startDate,
                                  endDate: self.endDate)
        
        return Event(withIdentifier: self.id,
                             ekEventID: self.ekEventID,
                             externalIdentifier: self.externalIdentifier,
                             calendar: self.calendar,
                             subscribed: state.isSubscribed,
                             alarm: alarm,
                             startDate: self.startDate,
                             endDate: self.endDate,
                             title: self.title,
                             location: self.location,
                             url: self.url,
                             notes: self.notes,
                             organizer: self.organizer)

    }

    init(withEvent EKEvent: EKEvent,
         calendar: Calendar,
         savedState: SavedState) {
        
        let alarm = Alarm(withSavedState: savedState.alarmState,
                                  startDate: EKEvent.startDate,
                                  endDate: EKEvent.endDate)

        self.init(withIdentifier: EKEvent.uniqueID,
                  ekEventID: EKEvent.eventIdentifier,
                  externalIdentifier: EKEvent.calendarItemExternalIdentifier,
                  calendar: calendar,
                  subscribed: savedState.isSubscribed,
                  alarm: alarm,
                  startDate: EKEvent.startDate,
                  endDate: EKEvent.endDate,
                  title: EKEvent.title,
                  location: EKEvent.location,
                  url: EKEvent.url,
                  notes: EKEvent.notes,
                  organizer: EKEvent.organizer?.name)
    }
    
}


