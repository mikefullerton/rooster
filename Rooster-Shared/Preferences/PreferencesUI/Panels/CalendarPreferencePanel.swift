//
//  CalendarPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class CalendarPreferencePanel : SDKViewController, PreferencePanel {
    
    let calendarChooser = CalendarChooserViewController()
    
    let boxView = GroupBoxView(frame: CGRect.zero,
                               title: "Choose calendars or delegate calendars to show events and reminders in Rooster",
                               groupBoxInsets: SDKEdgeInsets.zero,
                               groupBoxSpacing: SDKOffset.zero)
    
    func resetButtonPressed() {
        Controllers.dataModelController.enableAllPersonalCalendars()
    }
    
    override func loadView() {
        self.view = SDKView()
        self.view.addSubview(self.boxView)
        self.view.setFillInParentConstraints(forSubview: self.boxView)
        self.addChild(self.calendarChooser)
        self.boxView.setContainedViews([self.calendarChooser.view])
    }
    
    var toolbarButtonIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "calendars")
    }

}
