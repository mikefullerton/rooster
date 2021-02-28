//
//  MenuBarPreferencesPanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class MenuBarPreferencesPanel : SDKViewController, PreferencePanel {
    
    func resetButtonPressed() {
        Controllers.preferencesController.preferences = Preferences.default
    }
    
    override func loadView() {
        self.view = MenuBarChoicesView(frame: CGRect.zero)
    }
    
    var toolbarButtonIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "menubar")
    }


}

