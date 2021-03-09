//
//  MenuBarPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class MenuBarPreferencesPanel: PreferencePanel {
    override public var toolbarButtonIdentifier: String {
        "menubar"
    }

    override public func loadView() {
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView

        let notifs = GroupBoxView(title: "Rooster's behavior in the Menu Bar")

        notifs.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Rooster in Menu Bar",
                                       refresh: { AppControllers.shared.preferences.menuBar.options.contains( .showIcon ) },
                                       update: { AppControllers.shared.preferences.menuBar.options.set(.showIcon, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "Show count down to next meeting",
                                       refresh: { AppControllers.shared.preferences.menuBar.options.contains( .countDown ) },
                                       update: { AppControllers.shared.preferences.menuBar.options.set(.countDown, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "Blink Rooster when alarm is firing",
                                       refresh: { AppControllers.shared.preferences.menuBar.options.contains( .blink ) },
                                       update: { AppControllers.shared.preferences.menuBar.options.set(.blink, to: $0) })
        ])

        stackView.setContainedViews([
            notifs
        ])
    }
}
