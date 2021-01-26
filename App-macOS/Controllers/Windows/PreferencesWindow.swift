//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa

class PreferencesWindow: WindowController {
    
    static private weak var instance: PreferencesWindow?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.autosaveKey = "Preferences"
        self.setContentViewController(PreferencesViewController())
    }
        
    static func show() {
        if let windowController = PreferencesWindow.instance,
           let window = windowController.window {
            window.makeKeyAndOrderFront(self)
        } else {
            let windowController = PreferencesWindow()
            self.instance = windowController
            
            windowController.showWindow(self)
            
        }
    }
}
