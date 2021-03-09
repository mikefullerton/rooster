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
    
    private var storage: PreferencesStorage
    private var _preferences: Preferences?
    
    init() {
        self.storage = PreferencesStorage()
    }

    public func readFromStorage(completion: (_ success: Bool, _ error: NSError?) -> Void) {
        let prefs = storage.readOrCreatePreferences()
        _preferences = prefs
        self.removeOldPrefIfNeeded()
        
        completion(true, nil)
    }
    
    private func removeOldPrefIfNeeded() {
        if UserDefaults.standard.object(forKey: "preferences") != nil {
            UserDefaults.standard.removeObject(forKey: "preferences")
            UserDefaults.standard.synchronize()
        }
    }
    
    var general: GeneralPreferences {
        get { self.preferences.general }
        set { self.preferences.general = newValue }
    }
    
    var soundPreferences: SoundPreferences {
        get { self.preferences.soundPreferences }
        set { self.preferences.soundPreferences = newValue }
    }
    
    var menuBar: MenuBarPreferences {
        get { self.preferences.menuBar }
        set { self.preferences.menuBar = newValue }
    }
    
    var notifications: NotificationPreferences {
        get { self.preferences.notifications }
        set { self.preferences.notifications = newValue }
    }
    
    var dataModel: EKDataModelSettings {
        get { return self.preferences.dataModelPreferences }
        set { self.preferences.dataModelPreferences = newValue }
    }
    
    public var calendar: CalendarPreferences {
        get { return self.preferences.calendar }
        set { self.preferences.calendar = newValue }
    }
    
    public var preferences: Preferences {
        get {
            precondition(_preferences != nil, "Preferences accessed before loading")
            return _preferences ?? Preferences.default
        }
        set {
            let oldValue = self.preferences
            if oldValue != newValue {
                _preferences = newValue
                self.storage.writePreferences(newValue, previousPrefs: oldValue)
                self.notify(previousPrefs: oldValue)
            }
        }
    }
        
    public func delete() {
        do {
            try self.storage.delete()
            self.logger.log("Deleted preferences")
        } catch {
            self.logger.error("Deleting preferences failed with error: \(error.localizedDescription)")
        }
        
        self.notify(previousPrefs: nil)
    }

    // TODO: support individual settings
    func preferences(forItemIdentifier itemIdentifier: String) -> ItemPreference {
        return ItemPreference(with: self.preferences.soundPreferences)
    }
    
    private func notify(previousPrefs previousPrefsOrNil: Preferences?) {
        DispatchQueue.main.async {
            
            var userInfo: [String: Any]?
            
            if let previousPrefs = previousPrefsOrNil {
                userInfo = [
                    PreferencesController.OldPreferencesKey: previousPrefs,
                    PreferencesController.NewPreferencesKey: self.preferences
                ]
            }
            
            NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                            object: self,
                                            userInfo: userInfo)
        }
    }
}

extension PreferencesStorage {
    
    fileprivate func readOrCreatePreferences() -> Preferences {
        do {
            if self.exists {
                return try self.read()
            }
        } catch {
            self.logger.error("Reading old preferences failed with error: \(error.localizedDescription)")
        }
            
        let prefs = Preferences.default
        do {
            try self.write(prefs)
            self.logger.log("Wrote new preferences: \(prefs.description)")
        } catch {
            self.logger.error("Writing new preferences failed with error: \(error.localizedDescription)")
        }
        
        return prefs
    }
    
    fileprivate func writePreferences(_ preferences: Preferences, previousPrefs: Preferences) {
        do {
            try self.write(preferences)
        } catch {
            self.logger.error("Writing preferences failed with error: \(error.localizedDescription)")
        }

        self.logger.log("Wrote preferences: \(preferences.description)")
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
