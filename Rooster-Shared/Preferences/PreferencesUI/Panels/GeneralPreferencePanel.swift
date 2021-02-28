//
//  GeneralPreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation
import RoosterCore

class GeneralPreferencePanel : SDKViewController, PreferencePanel {
    
    func resetButtonPressed() {
        Controllers.preferencesController.preferences = Preferences.default

    }
    
    lazy var stackView = SimpleStackView(frame: CGRect.zero,
                                         direction: .vertical,
                                         insets: SDKEdgeInsets.ten,
                                         spacing: SDKOffset.zero)
    
    override func loadView() {
        self.view = self.stackView
        
        let box =  GroupBoxView(frame: CGRect.zero,
                                title: "General App Preferences",
                                groupBoxInsets: GroupBoxView.defaultGroupBoxInsets,
                                groupBoxSpacing: SDKOffset(horizontal: 0, vertical: 14))
        
        box.setContainedViews([
            GeneralPreferenceCheckboxView(withTitle: "Automatically launch Rooster", options: .automaticallyLaunch)
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
    
    var toolbarButtonIdentifier: NSToolbarItem.Identifier {
        return NSToolbarItem.Identifier(rawValue: "general")
    }
}
