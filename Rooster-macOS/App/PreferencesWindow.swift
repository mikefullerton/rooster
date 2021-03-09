//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa
import RoosterCore

public class PreferencesWindow: WindowController {
    private static weak var instance: PreferencesWindow?

    @IBOutlet private var viewController: PreferencesViewController?

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.autosaveKey = "Preferences"

        self.contentViewController = self.viewController
    }

    public static func show() {
        if let windowController = PreferencesWindow.instance,
           let window = windowController.window {
            window.makeKeyAndOrderFront(self)
        } else {
            let windowController = PreferencesWindow()
            self.instance = windowController

            windowController.showWindow(self)
        }
    }
}
