//
//  MenuBarPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class MenuBarPreferencesPanel: PreferencePanel {
    static var prefs: MenuBarPreferences {
        get { AppControllers.shared.preferences.menuBar }
        set { AppControllers.shared.preferences.menuBar = newValue }
    }

    override public func loadView() {
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView

        let notifs = GroupBoxView(title: "Rooster's behavior in the Menu Bar")

        notifs.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Rooster in Menu Bar",
                                       updater: { view in view.checkbox.isOn = Self.prefs.showInMenuBar },
                                       setter: { view in Self.prefs.showInMenuBar = view.checkbox.isOn }),

            SinglePreferenceChoiceView(withTitle: "Show count down to next meeting",
                                       updater: { view in view.checkbox.isOn = Self.prefs.showCountDown },
                                       setter: { view in Self.prefs.showCountDown = view.checkbox.isOn }),

            SinglePreferenceChoiceView(withTitle: "Blink Rooster when alarm is firing",
                                       updater: { view in view.checkbox.isOn = Self.prefs.blink },
                                       setter: { view in Self.prefs.blink = view.checkbox.isOn }),

            self.formatPopupMenu
        ])

        stackView.setContainedViews([
            notifs,
            SchedulePreferenceView(preferencesProvider: MenuBarPreferences.scheduleProvider)
        ])
    }

    private lazy var formatPopupMenu: PopupMenuPreferenceView = {
        var menuItems = [
            "Short (11d, 11h, 11m)",
            "Long (11 Days, 11 hours, 11 minutes)",
            "Digital Clock (11:11:11)"
        ]
        return PopupMenuPreferenceView(withTitle: "Count down text style:",
                                       menuItems: menuItems,
                                       refresh: { prefView in
                                            prefView.selectedItemIndex = Self.prefs.countDownFormat.rawValue
                                            prefView.isEnabled = Self.prefs.showCountDown
                                       },
                                       update: { prefView in
                                        if  let index = prefView.selectedItemIndex,
                                            let choice = MenuBarPreferences.CountDownFormat(rawValue: index) {
                                                Self.prefs.countDownFormat = choice
                                        }
                                       })
    }()

    override public var buttonTitle: String {
        "MenuBar"
    }

    override public var buttonImageTitle: String {
        "menubar.rectangle"
    }
}
