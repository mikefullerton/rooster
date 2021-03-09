//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa
import RoosterCore


class PreferencesWindow: WindowController {
    
    static private weak var instance: PreferencesWindow?
    
    @IBOutlet var viewController: PreferencesViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.autosaveKey = "Preferences"
        
        if let viewController = self.viewController {
            self.setContentViewController(viewController)
        }
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
