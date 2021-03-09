//
//  ModalWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa

open class ModalWindowController: WindowController {
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
