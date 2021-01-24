//
//  NSViewController+WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Foundation
import Cocoa

extension NSViewController {

    func presentInModalWindow(fromWindow window: NSWindow? = nil) {
        ModalWindowController.presentModallyWithViewController(withContentViewController: self, fromWindow: window)
    }

    func presentInWindow() {
        WindowController.presentWithViewController(withContentViewController: self)
    }

    func dismissWindow() {
        WindowController.dismissWindow(forViewController: self)
    }
    
    @objc func dismissWindowButtonPressed(_ sender: NSButton) {
        self.dismissWindow()
    }
}
