//
//  PreferencesWindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/21/21.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.contentViewController = PreferencesViewController()
    }
}
