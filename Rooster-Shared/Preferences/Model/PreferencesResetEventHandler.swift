//
//  PreferencesResetEventHandler.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/5/21.
//

import Foundation
import RoosterCore

public class PreferencesResetEventHandler {
    public typealias HandlerBlock = (_ newPrefs: Preferences) -> Void

    public var handler: HandlerBlock?

    public init(withHandler handler: HandlerBlock? = nil) {
        self.handler = handler

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferencesDidReset(_:)),
                                               name: PreferencesController.preferencesDidResetEvent,
                                               object: nil)
    }

    @objc private func preferencesDidReset(_ notification: Notification) {
        if let handler = self.handler,
           let newPrefs = notification.newPreferences {
            handler(newPrefs)
        }
    }
}
