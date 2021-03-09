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

    override public func loadView() {
        self.view = self.stackView

        let box = GroupBoxView(title: "General App Preferences")

        let generalPrefs = AppControllers.shared.preferences.general

        box.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Automatically launch Rooster",
                                       refresh: { generalPrefs.options.contains( .automaticallyLaunch ) },
                                       update: { AppControllers.shared.preferences.general.options.set(.automaticallyLaunch, to: $0) })
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }

    override public var toolbarButtonIdentifier: String {
        "general"
    }
}
