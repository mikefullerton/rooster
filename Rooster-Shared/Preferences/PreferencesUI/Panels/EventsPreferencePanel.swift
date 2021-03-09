//
//  EventsPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import RoosterCore

class EventsPreferencePanel : PreferencePanel {
    
    
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)
    
    override func loadView() {
        self.view = self.stackView
        
        let box =  GroupBoxView(title: "Events Preferences")
        
        box.setContainedViews([
            
            SinglePreferenceChoiceView(withTitle: "Show All Day Events",
                                       refresh: { Controllers.preferences.dataModel.allDayEvents },
                                       update: { Controllers.preferences.dataModel.allDayEvents = $0 }),
            
            SinglePreferenceChoiceView(withTitle: "Show Declined Events",
                                       refresh: { Controllers.preferences.dataModel.declinedEvents },
                                       update: { Controllers.preferences.dataModel.declinedEvents = $0 })

        ])

        self.stackView.setContainedViews( [
            box
        ])
    }
    

    open override var toolbarButtonIdentifier: String {
        return "events"
    }
}
