//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import RoosterCore

class PreferencesController: ObservableObject, Loggable {
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
   
    // in the user info in event notification
    static let NewPreferencesKey = "NewPreferencesKey"
    static let OldPreferencesKey = "OldPreferencesKey"
    
    private var storage: PreferencesStorage?

    init() {
        self.storage = try? PreferencesStorage()
        
        if UserDefaults.standard.object(forKey: "preferences") != nil {
            UserDefaults.standard.removeObject(forKey: "preferences")
            UserDefaults.standard.synchronize()
        }
    }
    
    var generalPreferences: GeneralPreferences {
        get {
            self.preferences.generalPreferences
        }
        
        set(newPrefs) {
            var prefs = self.preferences
            prefs.generalPreferences = newPrefs
            self.preferences = prefs
        }
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
            self.readOrCreatePreferences()
        }
        set(newPrefs) {
            self.writePreferences(newPrefs)
        }
    }
    
    public func delete() {
        
        if let storage = self.storage {
            do {
                try storage.delete()
                self.logger.log("Deleted preferences");
            } catch {
                self.logger.error("Deleting preferences failed with error: \(error.localizedDescription)")
            }
        } else {
            self.logger.error("No preferences storage")
        }
        
    }

    // TODO: support individual settings
    func preferences(forItemIdentifier itemIdentifier: String) -> ItemPreference {
        return ItemPreference(with: self.preferences.soundPreferences)
    }
}

extension PreferencesController {
    
    fileprivate func readOrCreatePreferences() -> Preferences {
        if let storage = self.storage {
            do {
                if storage.exists {
                    return try storage.read()
                }
            } catch {
                self.logger.error("Reading old preferences failed with error: \(error.localizedDescription)")
            }
                
            let prefs = Preferences.default
            do {
                try storage.write(prefs)
                self.logger.log("Wrote new preferences: \(prefs.description)")
            } catch {
                self.logger.error("Writing new preferences failed with error: \(error.localizedDescription)")
            }
            
            // this is dumb
            GlobalSoundVolume.volume = prefs.soundPreferences.volume
            
            return prefs
        } else {
            self.logger.error("No preferences storage")
        }
        
        return Preferences.default
    }
    
    fileprivate func writePreferences(_ preferences: Preferences) {
        let previousPrefs = self.preferences
        if let storage = self.storage {
      
            do {
                try storage.write(preferences)
            } catch {
                self.logger.error("Writing preferences failed with error: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                                object: self,
                                                userInfo: [
                                                    Self.OldPreferencesKey: previousPrefs,
                                                    Self.NewPreferencesKey: preferences
                                                ])
            
                // this is dumb
                GlobalSoundVolume.volume = preferences.soundPreferences.volume
            }
            
            self.logger.log("Wrote preferences: \(self.preferences.description)")
        } else {
            self.logger.error("No preferences storage")
        }
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
