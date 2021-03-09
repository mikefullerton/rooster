//
//  NSViewController+WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Foundation

import Cocoa

extension NSViewController {

    public func presentInModalWindow(fromWindow window: NSWindow? = nil) {
        ModalWindowController.presentModallyWithViewController(withContentViewController: self, fromWindow: window)
    }

    public func presentInWindow() {
        WindowController.presentWithViewController(withContentViewController: self)
    }

    public func dismissWindow() {
        WindowController.dismissWindow(forViewController: self)
    }
    
    @objc public func dismissWindowButtonPressed(_ sender: NSButton) {
        self.dismissWindow()
    }
}
