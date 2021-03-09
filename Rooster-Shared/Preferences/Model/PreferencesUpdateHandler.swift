//
//  EventKitDataModelUpdateHandler.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import RoosterCore

public class PreferencesUpdateHandler {
    public typealias HandlerBlock = (_ newPrefs: Preferences, _ oldPrefs: Preferences) -> Void

    public var handler: HandlerBlock?

    public init(withHandler handler: HandlerBlock? = nil) {
        self.handler = handler

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferencesDidChange(_:)),
                                               name: PreferencesController.preferencesDidChangeEvent,
                                               object: nil)
    }

    @objc private func preferencesDidChange(_ notification: Notification) {
        if  let newPrefs = notification.newPreferences,
            let oldPrefs = notification.oldPreferences {
            self.handler?(newPrefs, oldPrefs)
        }
    }
}
