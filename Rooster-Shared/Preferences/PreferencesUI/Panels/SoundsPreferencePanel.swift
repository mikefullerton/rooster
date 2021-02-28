//
//  SoundsPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class SoundsPreferencePanel : SDKViewController, PreferencePanel, SoundPreferencesViewDelegate {
    
    func resetButtonPressed() {
        Controllers.preferencesController.preferences = Preferences.default

    }
 
    lazy var soundPreferencesView = SoundPreferencesView()
    
    override func loadView() {
        self.view = self.soundPreferencesView
        
        self.soundPreferencesView.delegate = self
    }
    
    func soundPreferencesView(_ view: SoundPreferencesView,
                              presentSoundPickerForSoundIndex soundPreferenceKey: SoundPreferences.PreferenceKey) {
        
        SoundPickerViewController(withSoundPreferenceKey: soundPreferenceKey).presentInModalWindow(fromWindow: self.view.window)
    }

    var toolbarButtonIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "sounds")
    }

    
}
