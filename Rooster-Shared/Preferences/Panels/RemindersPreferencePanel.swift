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

    static var scheduleBehavior: ReminderScheduleBehavior {
        get { AppControllers.shared.preferences.scheduleBehavior.reminderScheduleBehavior }
        set { AppControllers.shared.preferences.scheduleBehavior.reminderScheduleBehavior = newValue }
    }

    override public func loadView() {
        self.view = self.stackView

        let box = GroupBoxView(title: "Reminder Preferences")
        box.setContainedViews([
            self.automaticallyUpgradePriorities,
            self.defaultReminderLength
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }

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
            prefView.selectedItemIndex = Self.scheduleBehavior.automaticallyIncreasePriorityDays
        }

        let update: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            Self.scheduleBehavior.automaticallyIncreasePriorityDays = prefView.selectedItemIndex ?? 0
        }

        return PopupMenuPreferenceView(withTitle: "Automatically increase Reminder priority after: ",
                                       menuItems: menuItems,
                                       refresh: refresh,
                                       update: update)
    }()

    // swiftlint:disable closure_body_length

    private lazy var defaultReminderLength: PopupMenuPreferenceView = {
        var menuItems: [String] = [
            "5 Minutes",
            "15 Minutes",
            "30 Minutes",
            "45 Minutes",
            "60 Minutes"
        ]

        let refresh: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            switch Self.scheduleBehavior.defaultLengthInMinutes {
            case 5:
                prefView.selectedItemIndex = 0

            case 15:
                prefView.selectedItemIndex = 1

            case 30:
                prefView.selectedItemIndex = 2

            case 45:
                prefView.selectedItemIndex = 4

            case 60:
                prefView.selectedItemIndex = 5

            default:
                prefView.selectedItemIndex = 1
                Self.scheduleBehavior.defaultLengthInMinutes = 15
            }
        }

        let update: (_ prefView: PopupMenuPreferenceView) -> Void = { prefView in
            switch prefView.selectedItemIndex {
            case 0:
                Self.scheduleBehavior.defaultLengthInMinutes = 5

            case 1:
                Self.scheduleBehavior.defaultLengthInMinutes = 15

            case 2:
                Self.scheduleBehavior.defaultLengthInMinutes = 30

            case 3:
                Self.scheduleBehavior.defaultLengthInMinutes = 45

            case 4:
                Self.scheduleBehavior.defaultLengthInMinutes = 60

            default:
                Self.scheduleBehavior.defaultLengthInMinutes = 15
            }
        }

        return PopupMenuPreferenceView(withTitle: "Default Reminder Length when shown on Schedule: ",
                                       menuItems: menuItems,
                                       refresh: refresh,
                                       update: update)
    }()

    override public var buttonTitle: String {
        "Reminders"
    }

    override public var buttonImageTitle: String {
        "checkmark.square"
    }
}
