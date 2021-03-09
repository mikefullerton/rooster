//
//  CalendarPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class KeyboardShortcutsPanel: PreferencePanel {
    static var prefs: KeyboardShortcutPreferences {
        get { AppControllers.shared.preferences.keyboardShortcut }
        set { AppControllers.shared.preferences.keyboardShortcut = newValue }
    }

    override public func loadView() {
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView

        let box = GroupBoxView(title: "Global Keyboard Shortcuts (experimental)")

        var views: [SDKView] = []

        for (index, shortcut) in Self.prefs.shortcuts.enumerated() {
            views.append(KeyboardShortcutPreferenceView(withTitle: shortcut.displayName,
                                                        updater: { view in
                                                            view.keyboardShortcut = Self.prefs.shortcuts[index]
                                                        }, setter: { view in
                                                            Self.prefs.shortcuts[index] = view.keyboardShortcut
                                                        }))
        }
        box.setContainedViews(views)
        stackView.setContainedViews([
            box
        ])
    }

    override public var buttonTitle: String {
        "Keyboard Shortcuts"
    }

    override public var buttonImageTitle: String {
        "keyboard"
    }
}

extension KeyboardShortcut {
    public var displayName: String {
        guard let id = KeyboardShortcutID(rawValue: self.id) else {
            return ""
        }

        switch id {
        case .mainWindow:
            return "Main Window"

        case .preferences:
            return "Preferences"

        case .calendars:
            return "Calendars"

        case .newReminder:
            return "New Reminder"

        case .stopAlarms:
            return "Stop Current Alarm"
        }
    }
}
