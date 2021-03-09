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
        windowController.contentViewController = viewController
        windowController.restoreVisibleState()

        self.presentWindowController(windowController,
                                     fromWindow: window)
    }

    override open func windowDidLoad() {
        super.windowDidLoad()

        if let window = self.window,
            let viewController = self.contentViewController {
            window.title = viewController.title ?? ""

            let preferredContentSize = viewController.preferredContentSize
            self.logger.log("""
                Updating \(type(of: self.contentViewController)) \
                window size: \(String(describing: preferredContentSize))
                """)

            window.setContentSize(preferredContentSize)
        }
    }

    override open func showWindow(_ sender: Any?) {
        super.showWindow(sender)

        if let window = self.window {
            NSApp.runModal(for: window)
        }
    }

    override open func close() {
        super.close()
        NSApp.abortModal()
    }
}
