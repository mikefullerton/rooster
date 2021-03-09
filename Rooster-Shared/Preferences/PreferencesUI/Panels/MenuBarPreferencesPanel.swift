//
//  MenuBarPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class MenuBarPreferencesPanel : PreferencePanel {
    
    
    open override var toolbarButtonIdentifier: String {
        return "menubar"
    }

    public override func loadView() {
        
        let stackView = SimpleStackView(direction: .vertical,
                                        insets: SDKEdgeInsets.ten,
                                        spacing: SDKOffset.zero)
        self.view = stackView
        
        let notifs =  GroupBoxView(title: "Rooster's behavior in the Menu Bar")
        
        notifs.setContainedViews([
            
            SinglePreferenceChoiceView(withTitle: "Show Rooster in Menu Bar",
                                       refresh: { Controllers.preferences.menuBar.options.contains( .showIcon ) },
                                       update: { Controllers.preferences.menuBar.options.set(.showIcon, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "Show count down to next meeting",
                                       refresh: { Controllers.preferences.menuBar.options.contains( .countDown ) },
                                       update: { Controllers.preferences.menuBar.options.set(.countDown, to: $0) }),

            SinglePreferenceChoiceView(withTitle: "Blink Rooster when alarm is firing",
                                       refresh: { Controllers.preferences.menuBar.options.contains( .blink ) },
                                       update: { Controllers.preferences.menuBar.options.set(.blink, to: $0) })
        ])

        stackView.setContainedViews([
            notifs
        ])
    }
    

}

