//
//  CheckingForUpdatesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/3/21.
//

import Cocoa

class CheckingForUpdatesWindow: WindowController {

    @IBOutlet var progressIndicator: NSProgressIndicator?
    
    static private weak var instance: CheckingForUpdatesWindow?
    
    override func windowDidLoad() {
        super .windowDidLoad()
        
        self.progressIndicator?.startAnimation(self)
    }
    
    static func show() {
        if let windowController = CheckingForUpdatesWindow.instance,
           let window = windowController.window {
            window.makeKeyAndOrderFront(self)
        } else {
            let windowController = CheckingForUpdatesWindow()
            self.instance = windowController
            
            windowController.showWindow(self)
        }
    }
    
    static func close() {
        if let instance = self.instance {
            instance.close()
        }
    }
    
}
