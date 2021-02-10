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
    
    private var storage: ApplicationSupportPreferencesFolder

    init() {
        self.storage = ApplicationSupportPreferencesFolder()
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
            do {
                if let prefs = try self.storage.read() {
                    return prefs
                }
            } catch {
                self.logger.error("Reading old preferences failed with error: \(error.localizedDescription)")
            }
                
            let prefs = Preferences()
            do {
                try self.storage.write(prefs)
                self.logger.log("Wrote new preferences: \(prefs.description)")
            } catch {
                self.logger.error("Writing new preferences failed with error: \(error.localizedDescription)")
                
            }
            return prefs
        }
        set(newPrefs) {
            let previousPrefs = self.preferences
            do {
                try self.storage.write(newPrefs)
            } catch {
                self.logger.error("Writing preferences failed with error: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                                object: self,
                                                userInfo: [
                                                    Self.OldPreferencesKey: previousPrefs,
                                                    Self.NewPreferencesKey: newPrefs
                                                ])
            }
            
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
