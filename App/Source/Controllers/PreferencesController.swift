//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class PreferencesController {
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
    
    private let dataStore: PreferencesDataStore
    
    public static let instance = PreferencesController()
 
    var preferences: Preferences
    
    private init() {
        self.preferences = Preferences()
        self.dataStore = PreferencesDataStore()
    }
    
    func notify() {
        NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                        object: self,
                                        userInfo: nil)
    }
    
    
    func soundPreference(forItem item: Alarmable) -> SoundPreference {
        let preference = SoundPreference(withSoundNames: [ "Rooster Crowing", "Chickens", "Rooster Crowing" ], repeatCount: SoundPreference.RepeatEndlessly)
        
        return preference
    }
    
    
    
    
}
