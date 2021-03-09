//
//  MenuBarPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

public class TodayWindowPreferencesPanel: PreferencePanel {
    static var prefs: TodayWindowPreferences {
        get { AppControllers.shared.preferences.todayWindowPreferences }
        set { AppControllers.shared.preferences.todayWindowPreferences = newValue }
    }

    override public func loadView() {
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView

        stackView.setContainedViews([
            SchedulePreferenceView(preferencesProvider: TodayWindowPreferences.scheduleProvider)
        ])
    }

    override public var buttonTitle: String {
        "Today Window"
    }

    override public var buttonImageTitle: String {
        "macwindow"
    }
}
