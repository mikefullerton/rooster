//
//  PreferencesWindow.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Cocoa
import RoosterCore

public class PreferencesWindow: WindowController {
    @IBOutlet private var viewController: PreferencesViewController?

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.autoSaveKey = AutoSaveKey("Preferences", alwaysShow: true)

        self.contentViewController = self.viewController
    }
}
