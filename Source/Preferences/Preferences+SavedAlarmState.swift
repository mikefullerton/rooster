//
//  Preferences+SavedAlarmState.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

extension EventKitAlarm {
    
    struct SavedState: DictionaryCodable {
        
        enum CodingKeys: String, CodingKey {
            case state = "state"
            case enabled = "enabled"
            case snoozeInterval = "snoozeInterval"
        }
        
        let state: State
        let isEnabled: Bool
        let snoozeInterval: TimeInterval
        
        init?(withDictionary dictionary: [AnyHashable : Any]) {
            guard let stateString = dictionary[CodingKeys.state.rawValue] as? String else {
                return nil
            }
            guard let enabledBool = dictionary[CodingKeys.enabled.rawValue] as? Bool  else {
                return nil
            }
            guard let snoozeInterval = dictionary[CodingKeys.snoozeInterval.rawValue] as? TimeInterval  else {
                return nil
            }

            self.state = EventKitAlarm.State(rawValue:stateString) ?? .neverFired
            self.isEnabled = enabledBool
            self.snoozeInterval = snoozeInterval
        }
        
        init(withAlarm alarm: EventKitAlarm) {
            self.state = alarm.state
            self.isEnabled = alarm.isEnabled
            self.snoozeInterval = alarm.snoozeInterval
        }
        
        var asDictionary: [AnyHashable : Any] {
            var dictionary: [AnyHashable : Any] = [:]
            dictionary[CodingKeys.state.rawValue] = self.state.rawValue
            dictionary[CodingKeys.enabled.rawValue] = self.isEnabled
            dictionary[CodingKeys.snoozeInterval.rawValue] = self.snoozeInterval
            return dictionary
        }
    }

    func update(withSavedState savedState: SavedState) -> EventKitAlarm {
        return EventKitAlarm(withState: savedState.state,
                             startDate: self.startDate,
                             endDate: self.endDate,
                             isEnabled: savedState.isEnabled,
                             snoozeInterval: savedState.snoozeInterval)
    }
    
    init(withSavedState state: SavedState,
         startDate: Date,
         endDate: Date?) {
        
        self.init(withState: state.state,
                  startDate: startDate,
                  endDate: endDate,
                  isEnabled: state.isEnabled,
                  snoozeInterval: state.snoozeInterval)
    }
}
