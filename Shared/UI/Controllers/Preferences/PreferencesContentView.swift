//
//  PreferencesContentView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation

protocol PreferencesContentView {
    func resetButtonWasPressed()
}

extension PreferencesContentView {
    
    func resetButtonWasPressed() {
        AppDelegate.instance.preferencesController.preferences = Preferences()
    }
}
