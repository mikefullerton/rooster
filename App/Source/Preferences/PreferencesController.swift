//
//  PreferencesDataModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class PreferencesController: ObservableObject, Loggable {
    static let DidChangeEvent = Notification.Name(rawValue: "PreferencesDidChangeEvent")
    
    private var storage: UserDefaults.IdentifierDictionary
    
    public static let instance = PreferencesController()
 
    @Published var preferences: Preferences {
        didSet {
            self.write()
        }
    }
    
    private init() {
        let storage = UserDefaults.IdentifierDictionary(withPreferencesKey: "preferences")
        
        var prefs: Preferences? = nil
        
        if let existingPrefences = storage.dictionary {
            prefs = Preferences(withDictionary: existingPrefences)
        } else {
            prefs = Preferences()
        }
        
        self.storage = storage
        self.preferences = prefs!
    }
    
    func notify() {
        NotificationCenter.default.post(name: PreferencesController.DidChangeEvent,
                                        object: self,
                                        userInfo: nil)
    }
    
    func preferences(forItemIdentifier itemIdentifier: String) -> ItemPreference {
        return ItemPreference(soundPreference: self.preferences.sounds)
    }
    
    private func write() {
        self.storage.dictionary = self.preferences.dictionaryRepresentation
        
        NotificationCenter.default.post(name: PreferencesController.DidChangeEvent, object: self)

        self.logger.log("Wrote preferences: \(self.preferences.description)")
    }
    
    func read() {
        var prefs: Preferences? = nil
        
        if let existingPrefences = self.storage.dictionary {
            prefs = Preferences(withDictionary: existingPrefences)
        } else {
            prefs = Preferences()
        }
        
        self.preferences = prefs!
        
        self.logger.log("Read preferences: \(self.preferences.description)")
    }
}
