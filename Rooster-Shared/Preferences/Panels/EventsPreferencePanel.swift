//
//  EventsPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import RoosterCore

public class EventsPreferencePanel: PreferencePanel {
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)

    static var prefs: EventPreferences {
        get { AppControllers.shared.preferences.events }
        set { AppControllers.shared.preferences.events = newValue }
    }

    override public func loadView() {
        self.view = self.stackView

        let box = GroupBoxView(title: "Events Preferences")

        let scheduleAllDayEvents = SinglePreferenceChoiceView(withTitle: "Schedule All Day Events with Notifications",
                                                              updater: { view in
                                                                    view.checkbox.isOn = Self.prefs.scheduleBehavior.scheduleAllDayEvents
                                                              },
                                                              setter: { view in
                                                                    Self.prefs.scheduleBehavior.scheduleAllDayEvents = view.checkbox.isOn
                                                              })

        let showAllDayEvents = SinglePreferenceChoiceView(withTitle: "Show All Day Events",
                                                          updater: { view in
                                                                view.checkbox.isOn = Self.prefs.scheduleBehavior.showAllDayEvents
                                                          },
                                                          setter: { view in
                                                                Self.prefs.scheduleBehavior.showAllDayEvents = view.checkbox.isOn
                                                                scheduleAllDayEvents.isEnabled = view.checkbox.isOn
                                                          })

        let declinedEvents = SinglePreferenceChoiceView(withTitle: "Show Declined Events",
                                                        updater: { view in view.checkbox.isOn = Self.prefs.scheduleBehavior.showDeclinedEvents },
                                                        setter: { view in Self.prefs.scheduleBehavior.showDeclinedEvents = view.checkbox.isOn })

        box.setContainedViews([
            showAllDayEvents,
            scheduleAllDayEvents,
            declinedEvents
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }

    override public var buttonTitle: String {
        "Events"
    }

    override public var buttonImageTitle: String {
        "calendar"
    }
}
