//
//  EventsPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import RoosterCore

public class RemindersPreferencePanel: PreferencePanel {
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)

    public static var prefs: ReminderPreferences {
        get { AppControllers.shared.preferences.reminders }
        set { AppControllers.shared.preferences.reminders = newValue }
    }

    override public func loadView() {
        self.view = self.stackView

        let allReminders = GroupBoxView(title: "All Reminders")

        allReminders.setContainedViews([
            self.automaticallyUpgradePriorities
        ])

        let unscheduledReminders = GroupBoxView(title: "Unschedule Reminders (Reminders with no due date)")

        unscheduledReminders.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Unscheduled Reminders",
                                       refresh: { Self.prefs.scheduleBehavior.showAllReminders },
                                       update: { Self.prefs.scheduleBehavior.showAllReminders = $0 }),
            self.minumumPriorityFilterMenu
        ])

        self.stackView.setContainedViews( [
            allReminders,
            unscheduledReminders
        ])
    }

    // swiftlint:disable closure_body_length

    private lazy var minumumPriorityFilterMenu: PopupMenuPreferenceView = {
        var menuItems: [String] = [
            "No Priority (-)",
            "Low Priority (!)",
            "Medium Priority (!!)",
            "High Priority !!!"
        ]

        let refresh: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            prefView.isEnabled = Self.prefs.scheduleBehavior.showAllReminders

            switch Self.prefs.scheduleBehavior.priorityFilter {
            case .none:
                prefView.selectedItemIndex = 0

            case .low:
                prefView.selectedItemIndex = 1

            case .medium:
                prefView.selectedItemIndex = 2

            case .high:
                prefView.selectedItemIndex = 3
            }
        }

        let update: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            switch prefView.selectedItemIndex {
            case 0:
                Self.prefs.scheduleBehavior.priorityFilter = .none

            case 1:
                Self.prefs.scheduleBehavior.priorityFilter = .low

            case 2:
                Self.prefs.scheduleBehavior.priorityFilter = .medium

            case 3:
                Self.prefs.scheduleBehavior.priorityFilter = .high

            default:
                break
            }
        }

        return PopupMenuPreferenceView(withTitle: "Only show Unscheduled Reminders with at least: ",
                                       menuItems: menuItems,
                                       refresh: refresh,
                                       update: update)
    }()

    private lazy var automaticallyUpgradePriorities: PopupMenuPreferenceView = {
        // FUTURE: make a nicer more flexible date range control

        var menuItems: [String] = [
            "Never",
            "1 Day",
            "2 Days",
            "3 Days",
            "4 Days",
            "5 Days",
            "6 Days",
            "1 Week"
        ]

        let refresh: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            prefView.selectedItemIndex = Self.prefs.scheduleBehavior.automaticallyIncreasePriorityDays
        }

        let update: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            Self.prefs.scheduleBehavior.automaticallyIncreasePriorityDays = prefView.selectedItemIndex ?? 0
        }

        return PopupMenuPreferenceView(withTitle: "Automatically increase Reminder priority after: ",
                                       menuItems: menuItems,
                                       refresh: refresh,
                                       update: update)
    }()

    // swiftlint:enable closure_body_length

    override public var toolbarButtonIdentifier: String {
        "reminders"
    }
}
