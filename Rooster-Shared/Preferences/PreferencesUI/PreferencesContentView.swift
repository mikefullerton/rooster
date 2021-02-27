//
//  PreferencesContentView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
import RoosterCore

protocol PreferencesContentView {
    func resetButtonWasPressed()
}

extension PreferencesContentView {
    
    func resetButtonWasPressed() {
        Controllers.preferencesController.preferences = Preferences()
    }
}
