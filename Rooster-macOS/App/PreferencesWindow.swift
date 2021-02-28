//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa

class PreferencesWindow: WindowController {
    
    static private weak var instance: PreferencesWindow?
    
    @IBOutlet var viewController: PreferencesViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.autosaveKey = "Preferences"
        
        if let viewController = self.viewController {
            self.setContentViewController(viewController)
            
//            if let window = self.window {
//                let preferredContentSize = viewController.preferredContentSize
//                self.logger.log("Updating prefs window size: \(NSStringFromSize(preferredContentSize))")
//                window.setContentSize(preferredContentSize)
//            }
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
    
//    @IBAction @objc close(_ sender: Any?) {
//        
//        self.cl
//    }
}
