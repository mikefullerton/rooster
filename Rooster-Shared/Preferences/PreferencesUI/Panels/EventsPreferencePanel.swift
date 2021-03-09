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
                                                              refresh: { Self.prefs.scheduleBehavior.scheduleAllDayEvents },
                                                              update: { Self.prefs.scheduleBehavior.scheduleAllDayEvents = $0 })

        let showAllDayEvents = SinglePreferenceChoiceView(withTitle: "Show All Day Events",
                                                          refresh: { Self.prefs.scheduleBehavior.showAllDayEvents },
                                                          update: {
                                                                Self.prefs.scheduleBehavior.showAllDayEvents = $0
                                                                scheduleAllDayEvents.isEnabled = $0
                                                          })

        let declinedEvents = SinglePreferenceChoiceView(withTitle: "Show Declined Events",
                                                        refresh: { Self.prefs.scheduleBehavior.showDeclinedEvents },
                                                        update: { Self.prefs.scheduleBehavior.showDeclinedEvents = $0 })

        box.setContainedViews([
            showAllDayEvents,
            scheduleAllDayEvents,
            declinedEvents
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }

    override public var toolbarButtonIdentifier: String {
        "events"
    }
}
