//
//  CalendarPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class CalendarPreferencePanel : PreferencePanel {
    
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)
    
    override func loadView() {
        self.view = self.stackView
        
        let boxView = GroupBoxView(title: "How many calendar days to show")
        boxView.setContainedViews([
            
            SinglePreferenceChoiceView(withTitle: "Show Calendar Name on Events and Reminders",
                                       refresh: { Controllers.preferences.calendar.options.contains( .showCalendarName ) },
                                       update: { Controllers.preferences.calendar.options.set(.showCalendarName, to:$0) }),

            DayCountSlider()
        ])
        
        self.stackView.setContainedViews( [
            boxView
        ])
    }
    
    open override var toolbarButtonIdentifier: String {
        return "calendars"
    }

}
