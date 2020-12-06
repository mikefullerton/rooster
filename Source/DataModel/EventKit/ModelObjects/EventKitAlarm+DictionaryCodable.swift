//
//  EventKitAlarm+DictionaryCodable.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension EventKitAlarm: DictionaryCodable {
    
    enum CodingKeys: String, CodingKey {
        case state = "state"
        case date = "date"
        case enabled = "enabled"
        case snooze = "snooze"
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {
        guard let stateString = dictionary[CodingKeys.state.rawValue] as? String else {
            return nil
        }
        guard let dateInterval = dictionary[CodingKeys.date.rawValue] as? TimeInterval else {
            return nil
        }
        guard let enabledBool = dictionary[CodingKeys.enabled.rawValue] as? Bool  else {
            return nil
        }
        guard let snoozeInterval = dictionary[CodingKeys.snooze.rawValue] as? TimeInterval  else {
            return nil
        }

        self.state = State(rawValue:stateString) ?? .neverFired
        self.date = Date(timeIntervalSinceReferenceDate:dateInterval)
        self.isEnabled = enabledBool
        self.snoozeInterval = snoozeInterval
    }
    
    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.state.rawValue] = self.state.rawValue
        dictionary[CodingKeys.date.rawValue] = self.date.timeIntervalSince1970
        dictionary[CodingKeys.enabled.rawValue] = self.isEnabled
        dictionary[CodingKeys.snooze.rawValue] = self.snoozeInterval
        return dictionary
    }
}
