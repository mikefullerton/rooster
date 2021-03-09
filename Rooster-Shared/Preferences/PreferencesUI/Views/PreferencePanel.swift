//
//  PreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

open class PreferencePanel: SDKViewController, Loggable {
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    open var toolbarButtonIdentifier: String {
        ""
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.preferencesUpdateHandler.handler = { [weak self] newPrefs, oldPrefs in
            guard let self = self else {
                return
            }

            self.preferencesDidChange(newPrefs, oldPrefs)
        }
    }

    open func preferencesDidChange(_ oldPrefs: Preferences, _ newPrefs: Preferences) {
    }

    open func resetButtonPressed() {
        AppControllers.shared.preferences.preferences = Preferences.default
    }
}
