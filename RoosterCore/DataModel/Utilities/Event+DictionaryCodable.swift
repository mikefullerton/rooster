//
//  RCEvent+DictionaryCodable.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/22/20.
//

import Foundation
import EventKit

extension RCEvent {

    // represents the small subset of data we actually store for an RCEvent
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
        
        public init(withEvent event: RCEvent) {
            self.isSubscribed = event.isSubscribed
            self.alarmState = RCAlarm.SavedState(withAlarm: event.alarm)
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
            dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
            dictionary[CodingKeys.alarm.rawValue] = self.alarmState.dictionaryRepresentation
            return dictionary
        }
    }
    
    public func update(withSavedState state: SavedState) -> RCEvent {
        
        let alarm = RCAlarm(withSavedState: state.alarmState,
                            startDate: self.startDate,
                            endDate: self.endDate,
                            canExpire: true)
        
        return RCEvent(withIdentifier: self.id,
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

    public init(withEvent EKEvent: EKEvent,
                calendar: RCCalendar,
                savedState: SavedState) {
        
        let alarm = RCAlarm(withSavedState: savedState.alarmState,
                            startDate: EKEvent.startDate,
                            endDate: EKEvent.endDate,
                            canExpire: true)

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


