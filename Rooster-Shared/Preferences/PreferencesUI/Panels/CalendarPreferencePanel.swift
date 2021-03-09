//
//  CalendarPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class CalendarPreferencePanel: PreferencePanel {
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)

    static var prefs: CalendarPreferences {
        get { AppControllers.shared.preferences.calendar }
        set { AppControllers.shared.preferences.calendar = newValue }
    }

    override public func loadView() {
        self.view = self.stackView

        let calendarOptionsBox = GroupBoxView(title: "Calendar Preferences")
        calendarOptionsBox.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Calendar Name on Events and Reminders",
                                       refresh: { Self.prefs.options.contains( .showCalendarName ) },
                                       update: { Self.prefs.options.set(.showCalendarName, to: $0) }),
            self.daysPopupMenu
        ])

        self.stackView.setContainedViews( [
            calendarOptionsBox
        ])
    }

    private lazy var daysPopupMenu: PopupMenuPreferenceView = {
        var menuItems: [String] = []
        for i in 1...6 {
            let title = i > 1 ? "\(i) Days" : "\(i) Day"
            menuItems.append(title)
        }
        menuItems.append("1 Week")

        return PopupMenuPreferenceView(withTitle: "Number of days to show (experimental):",
                                       menuItems: menuItems,
                                       refresh: { prefView in
                                            prefView.selectedItemIndex = Self.prefs.scheduleBehavior.visibleDayCount - 1
                                       },
                                       update: { prefView in
                                            Self.prefs.scheduleBehavior.visibleDayCount = (prefView.selectedItemIndex ?? 0) + 1
                                       })
    }()

    override public var toolbarButtonIdentifier: String {
        "calendars"
    }
}
