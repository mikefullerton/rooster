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

    //    static func presentWindowController(_ windowController: NSWindowController) {
//        if let window = windowController.window {
//
//            self.logger.log("Presenting modal window for: \(String(describing:windowController)).\(String(describing:windowController.contentViewController))")
//
//            windowController.showWindow(self)
//
//            self.visibleControllers.append(windowController)
//
//            NSApp.runModal(for: window)
//
//            window.orderOut(self)
//
//            if let index = self.visibleControllers.firstIndex(of: windowController) {
//                self.visibleControllers.remove(at: index)
//            }
//
//            self.logger.log("Finished presenting modal window for: \(String(describing:windowController)).\(String(describing:windowController.contentViewController))")
//
//        } else {
//            self.logger.error("Failed to load window for \(windowController)")
//        }
//    }
//
//    static func dismiss() {
//        if self.visibleControllers.count > 0 {
//            NSApp.abortModal()
//        }
//    }
//
//    override func dismiss() {
//        NSApp.abortModal()
//    }
    
//    static func dismissWindow(forViewController viewController: NSViewController) {
//        for visibleController in self.visibleControllers {
//            if visibleController.contentViewController == viewController {
//                self.dismiss()
//                break
//            }
//        }
//    }
//
//    func presentModally() {
//        ModalWindowController.presentWindowController(self)
//    }
//
  
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

