//
//  Preferences+SavedAlarmState.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

extension Alarm {
    
    struct SavedState: DictionaryCodable {
        
        enum CodingKeys: String, CodingKey {
            case enabled = "enabled"
            case snoozeInterval = "snoozeInterval"
            case mutedDate = "mutedDate"
        }
        
        let isEnabled: Bool
        let mutedDate: Date?
        let snoozeInterval: TimeInterval
        
        init?(withDictionary dictionaryOrNil: [AnyHashable : Any]?) {
            
            if let dictionary = dictionaryOrNil {
                guard let enabledBool = dictionary[CodingKeys.enabled.rawValue] as? Bool  else {
                    return nil
                }
                guard let snoozeInterval = dictionary[CodingKeys.snoozeInterval.rawValue] as? TimeInterval  else {
                    return nil
                }
                
                let mutedDateInterval = dictionary[CodingKeys.mutedDate.rawValue] as? TimeInterval

                self.isEnabled = enabledBool
                self.snoozeInterval = snoozeInterval
                self.mutedDate = mutedDateInterval == nil ?
                                    nil :
                                    Date(timeIntervalSinceReferenceDate: mutedDateInterval!)
            } else {
                return nil
            }
        }
        
        init(withAlarm alarm: Alarm) {
            self.isEnabled = alarm.isEnabled
            self.snoozeInterval = alarm.snoozeInterval
            self.mutedDate = alarm.mutedDate
        }
        
        var dictionaryRepresentation: [AnyHashable : Any] {
            var dictionary: [AnyHashable : Any] = [:]
            dictionary[CodingKeys.enabled.rawValue] = self.isEnabled
            dictionary[CodingKeys.snoozeInterval.rawValue] = self.snoozeInterval
            dictionary[CodingKeys.mutedDate.rawValue] = self.mutedDate?.timeIntervalSinceReferenceDate
            return dictionary
        }
    }

    func update(withSavedState savedState: SavedState) -> Alarm {
        return Alarm(startDate: self.startDate,
                     endDate: self.endDate,
                     isEnabled: savedState.isEnabled,
                     mutedDate: savedState.mutedDate,
                     snoozeInterval: savedState.snoozeInterval)
    }
    
    init(withSavedState state: SavedState,
         startDate: Date,
         endDate: Date) {
        
        self.init(startDate: startDate,
                  endDate: endDate,
                  isEnabled: state.isEnabled,
                  mutedDate: state.mutedDate,
                  snoozeInterval: state.snoozeInterval)
    }
}
