//
//  GeneralPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class GeneralPreferencePanel: PreferencePanel {
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)

    public static var prefs: GeneralPreferences {
        get { AppControllers.shared.preferences.general }
        set { AppControllers.shared.preferences.general = newValue }
    }

    override public func loadView() {
        self.view = self.stackView

        let box = GroupBoxView(title: "General App Preferences")

        box.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Automatically launch Rooster",
                                       updater: { view in view.checkbox.isOn = Self.prefs.automaticallyLaunch },
                                       setter: { view in Self.prefs.automaticallyLaunch = view.checkbox.isOn }),

            SinglePreferenceChoiceView(withTitle: "Show Rooster's App Icon in Dock",
                                       updater: { view in view.checkbox.isOn = Self.prefs.showInDock },
                                       setter: { view in Self.prefs.showInDock = view.checkbox.isOn })
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }

    override public var buttonTitle: String {
        "General"
    }

    override public var buttonImageTitle: String {
        "gear"
    }
}
