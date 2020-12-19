//
//  Preferences+Sounds.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation

extension Preferences {
    
    struct Sounds : DictionaryCodable {
        var alarmSound: String?
        
        enum Keys : String, CodingKey {
            case alarmSound = "alarmSound"
        }
        
        init() {
            self.alarmSound = nil
        }
     
        init(withDictionary dictionary: [AnyHashable: Any]) {
            self.alarmSound = dictionary[Keys.alarmSound.rawValue] as? String
        }
        
        var asDictionary: [AnyHashable: Any]  {
            
            var outDictionary: [AnyHashable: Any] = [:]
            
            if self.alarmSound != nil {
                outDictionary[Keys.alarmSound.rawValue] = self.alarmSound!
            }
            
            return outDictionary
        }
    }
    
}
