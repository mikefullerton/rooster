//
//  NSViewController+WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Foundation

import Cocoa
import AppKit

extension NSViewController {
    public func showInModalWindow(centeredOnWindow window: NSWindow) {
        ModalWindowController.show(withContentViewController: self, centeredOnWindow: window)
    }

    public func showInModalWindow(withAutoSaveKey autoSaveKey: NSWindowController.AutoSaveKey? = nil) {
        ModalWindowController.show(withContentViewController: self, autoSaveKey: autoSaveKey)
    }

    public func showInWindow(withAutoSaveKey autoSaveKey: NSWindowController.AutoSaveKey? = nil) {
        WindowController.show(withContentViewController: self, autoSaveKey: autoSaveKey)
    }

    public func hideWindow() {
        WindowController.hide(forViewController: self)
    }

    @objc public func dismissWindowButtonPressed(_ sender: NSButton) {
        self.hideWindow()
    }
}
