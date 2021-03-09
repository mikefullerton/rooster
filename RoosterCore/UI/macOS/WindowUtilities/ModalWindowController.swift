//
//  ModalWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa

open class ModalWindowController: WindowController {

    public static func presentModallyWithViewController(withContentViewController viewController: NSViewController,
                                                 fromWindow window: NSWindow? = nil) {
        let windowController = ModalWindowController()
        windowController.setContentViewController(viewController)
        self.presentWindowController(windowController,
                                     fromWindow: window)
    }
    
    open override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = self.window,
            let viewController = self.contentViewController {
                
            window.title = viewController.title ?? ""
                
            let preferredContentSize = viewController.preferredContentSize
            self.logger.log("Updating \(type(of:self.contentViewController)) window size: \(NSStringFromSize(preferredContentSize))")
            window.setContentSize(preferredContentSize)
        }
    }

    open override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        if let window = self.window {
            NSApp.runModal(for: window)
        }
    }
    
    open override func close() {
        super.close()
        NSApp.abortModal()
    }

}

