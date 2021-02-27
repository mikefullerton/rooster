//
//  ModalWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa

class ModalWindowController: WindowController {

    static func presentModallyWithViewController(withContentViewController viewController: NSViewController,
                                                 fromWindow window: NSWindow? = nil) {
        let windowController = WindowController()
        windowController.setContentViewController(viewController)
        self.presentWindowController(windowController,
                                     fromWindow: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        if let window = self.window {
            NSApp.runModal(for: window)
        }
    }
    
    override func close() {
        super.close()
        NSApp.abortModal()
    }

}

