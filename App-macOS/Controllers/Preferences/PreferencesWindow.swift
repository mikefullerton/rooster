//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa

class PreferencesWindow: WindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        self.autosaveKey = "Preferences"
        self.setContentViewController(PreferencesViewController())
    }
}
