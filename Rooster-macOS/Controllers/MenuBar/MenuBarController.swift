//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import RoosterCore
import AppKit

 
class MenuBarController: Loggable, DataModelAware {
        
    private var reloader: DataModelReloader? = nil
    
    lazy var primaryMenuItem = MenuBarMenuItem()
    
    init() {
        self.reloader = DataModelReloader(for: self)
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
    }
    
    var prefs: MenuBarPreferences {
        return Controllers.preferencesController.menuBarPreferences
    }
    
    func updateMenuBarItemsVisibility() {
        
        let prefs = self.prefs
        
        if prefs.options.contains(.showIcon) {
            self.primaryMenuItem.isVisible = true

            if !prefs.options.contains(.countDown) {
                self.primaryMenuItem.stopCountdown()
            }
            
        } else {
            self.primaryMenuItem.isVisible = false
        }
    }
    
    func showInMenuBar() {
        self.updateMenuBarItemsVisibility()
    }

    func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        
        let prefs = self.prefs
        
        if prefs.options.contains(.showIcon) {
            self.primaryMenuItem.alarmStateDidChange()
            
        } else {
            self.primaryMenuItem.stopCountdown()
        }
    }
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.updateMenuBarItemsVisibility()
    }

}
