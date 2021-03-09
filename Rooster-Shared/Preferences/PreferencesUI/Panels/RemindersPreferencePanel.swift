//
//  EventsPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/23/21.
//

import Foundation
import RoosterCore

class RemindersPreferencePanel : PreferencePanel {
        
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)
    
    override func loadView() {
        self.view = self.stackView
        
        let box =  GroupBoxView(title: "Reminders Preferences")
        
        box.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Show Reminders with no Due Date",
                                       refresh: { Controllers.preferences.dataModel.remindersWithNoDates },
                                       update: { Controllers.preferences.dataModel.remindersWithNoDates = $0 })
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }
    
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override var toolbarButtonIdentifier: String {
        return "reminders"
    }
}
