//
//  NotificationChoicesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class MenuBarChoicesView : SimpleStackView {
    
    init(frame: CGRect) {
        super.init(direction: .vertical,
                   insets: SDKEdgeInsets.ten,
                   spacing: SDKOffset.zero)
        
        let notifs =  GroupBoxView(frame: CGRect.zero,
                                   title: "Rooster's behavior in the Menu Bar",
                                   groupBoxInsets: GroupBoxView.defaultGroupBoxInsets,
                                   groupBoxSpacing: SDKOffset(horizontal: 0, vertical: 14))
        
        notifs.setContainedViews([
            self.showInMenuBar,
            self.showCountdown,
//            self.shortCountdown,
            self.blink
        ])

        self.setContainedViews([
            notifs
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var showInMenuBar : SinglePreferenceChoiceView = {
        return MenuBarPreferenceView(title: "Show Rooster in Menu Bar", option: .showIcon)
    }()

    lazy var showCountdown : SinglePreferenceChoiceView = {
        return MenuBarPreferenceView(title: "Show count down to next meeting", option: .countDown)
    }()

    lazy var shortCountdown : SinglePreferenceChoiceView = {
        return MenuBarPreferenceView(title: "Use short countdown time", option: .shortCountdownFormat)
    }()

    lazy var blink : SinglePreferenceChoiceView = {
        return MenuBarPreferenceView(title: "Blink Rooster when alarm is firing", option: .blink)
    }()
}

class MenuBarPreferenceView: SinglePreferenceChoiceView {

    let option:MenuBarPreferences.Options
    
    init(title: String, option: MenuBarPreferences.Options) {
        self.option = option
        super.init(frame: CGRect.zero,
                   title: title)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func checkboxChanged(_ sender: NSButton) {
        
        var prefs = Controllers.preferencesController.menuBarPreferences
        
        if sender.intValue == 1 {
            prefs.options.insert(self.option)
        } else {
            prefs.options.remove(self.option)
        }
        
        Controllers.preferencesController.menuBarPreferences = prefs
    }

    override var value: Bool {
        return Controllers.preferencesController.menuBarPreferences.options.contains(self.option)
    }
    
    override func refresh() {
        super.refresh()
        
        if self.option == .shortCountdownFormat {
            self.checkbox.isEnabled = Controllers.preferencesController.menuBarPreferences.options.contains([.countDown, .showIcon])
        }
        
        self.checkbox.isEnabled =   self.option == .showIcon ||
                                    Controllers.preferencesController.menuBarPreferences.options.contains(.showIcon)
    }
}
