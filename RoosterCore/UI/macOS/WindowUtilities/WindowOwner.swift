//
//  WindowOwner.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/21/21.
//

import AppKit
import Foundation

public class WindowOwner {
    private weak var windowController: NSWindowController?

    private var factory: () -> NSWindowController

    public init(withFactory factory: @escaping () -> NSWindowController) {
        self.factory = factory
    }

    public func show() {
        if let windowController = self.windowController {
            windowController.window?.makeKeyAndOrderFront(self)
        } else {
            let windowController = self.factory()
            self.windowController = windowController
        }
    }
}
