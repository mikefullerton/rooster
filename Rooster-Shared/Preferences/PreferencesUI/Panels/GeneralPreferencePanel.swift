//
//  GeneralPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class GeneralPreferencePanel : PreferencePanel {
    
    lazy var stackView = SimpleStackView(direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)
    
    override func loadView() {
        self.view = self.stackView
        
        let box =  GroupBoxView(title: "General App Preferences")
        
        let generalPrefs = Controllers.preferences.general
        
        box.setContainedViews([
            SinglePreferenceChoiceView(withTitle: "Automatically launch Rooster",
                                       refresh: { generalPrefs.options.contains( .automaticallyLaunch ) },
                                       update: { Controllers.preferences.general.options.set(.automaticallyLaunch, to: $0) })
        ])

        self.stackView.setContainedViews( [
            box
        ])
    }
    
    
    open override var toolbarButtonIdentifier: String {
        return "general"
    }
}
