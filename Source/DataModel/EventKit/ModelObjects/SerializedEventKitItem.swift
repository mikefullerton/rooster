//
//  SerializedEventKitItem.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

struct SerializedEventKitItem<T>: DictionaryCodable, Identifiable where T: EventKitItem {

    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case subscribed = "subscribed"
        case alarm = "alarm"
    }
    
    let id: String
    let alarm: EventKitAlarm
    let isSubscribed: Bool
    
    init(withIdentifier id: String,
         isSubscribed: Bool,
         alarm: EventKitAlarm) {
        self.id = id
        self.alarm = alarm
        self.isSubscribed = isSubscribed
    }
    
    init(withEventKitItem item: T) {
        self.id = item.id
        self.alarm = item.alarm
        self.isSubscribed = item.isSubscribed
    }
    
    init?(withDictionary dictionary: [AnyHashable : Any]) {

        guard let idString = dictionary[CodingKeys.id.rawValue] as? String else {
            return nil
        }
        guard let alarmDictionary = dictionary[CodingKeys.alarm.rawValue] as? [AnyHashable: Any] else {
            return nil
        }
        guard let subscribedBool = dictionary[CodingKeys.subscribed.rawValue] as? Bool  else {
            return nil
        }
        guard let alarm = EventKitAlarm(withDictionary: alarmDictionary) else {
            return nil
        }

        self.id = idString
        self.isSubscribed = subscribedBool
        self.alarm = alarm
    }

    var asDictionary: [AnyHashable : Any] {
        var dictionary: [AnyHashable : Any] = [:]
        dictionary[CodingKeys.id.rawValue] = self.id
        dictionary[CodingKeys.subscribed.rawValue] = self.isSubscribed
        dictionary[CodingKeys.alarm.rawValue] = self.alarm.asDictionary
        return dictionary
    }
}
