//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class PreferencesController: ObservableObject, Loggable {
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
   
    // in the user info in event notification
    static let NewPreferencesKey = "NewPreferencesKey"
    static let OldPreferencesKey = "OldPreferencesKey"
    
    private var storage: UserDefaults.IdentifierDictionary

    init() {
        self.storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "preferences")
    }
    
    var soundPreferences: SoundPreferences {
        get {
            self.preferences.soundPreferences
        }
        
        set(newPrefs) {
            var prefs = self.preferences
            prefs.soundPreferences = newPrefs
            self.preferences = prefs
        }
    }
    
    var menuBarPreferences: MenuBarPreferences {
        get {
            self.preferences.menuBarPreferences
        }
        
        set(newPrefs) {
            var prefs = self.preferences
            prefs.menuBarPreferences = newPrefs
            self.preferences = prefs
        }
    }
    
    var notificationPreferences: NotificationPreferences {
        get {
            self.preferences.notificationPreferences
        }
        
        set(newPrefs) {
            var prefs = self.preferences
            prefs.notificationPreferences = newPrefs
            self.preferences = prefs
        }
    }
    
    var preferences: Preferences {
        get {
            if let prefsDictionary = self.storage.dictionary {
                return Preferences(withDictionary: prefsDictionary)
            }
            
            return Preferences()
        }
        set(newPrefs) {
            let previousPrefs = self.preferences
            
            self.storage.dictionary = newPrefs.dictionaryRepresentation

            NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                            object: self,
                                            userInfo: [
                                                Self.OldPreferencesKey: previousPrefs,
                                                Self.NewPreferencesKey: newPrefs
                                            ])

            self.logger.log("Wrote preferences: \(self.preferences.description)")
        }
    }

    // TODO: support individual settings
    func preferences(forItemIdentifier itemIdentifier: String) -> ItemPreference {
        return ItemPreference(with: self.preferences.soundPreferences)
    }
    
}

extension Notification {
    var oldPreferences : Preferences? {
        return self.userInfo?[PreferencesController.OldPreferencesKey] as? Preferences
    }
    var newPreferences : Preferences? {
        return self.userInfo?[PreferencesController.NewPreferencesKey] as? Preferences
    }

}
