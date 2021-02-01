//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import AppKit

 
class MenuBarController: Loggable,
                        AppControllerAware,
                        PrimaryMenuBarItemDelegate,
                        StopAlarmMenuBarButtonDelegate,
                        DataModelAware {
        
    struct Options: OptionSet {
        let rawValue: Int
        
        static let none             = Options(rawValue: 1 << 0)
        static let icon             = Options(rawValue: 1 << 1)
        static let countDown        = Options(rawValue: 1 << 2)
        static let popoverView      = Options(rawValue: 1 << 3)
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    private var reloader: DataModelReloader? = nil
    
    lazy var primaryMenuItem = PrimaryMenuBarItem(withDelegate: self)
    lazy var stopAlarmItem = StopAlarmMenuBarButton(withDelegate: self)
    
    init() {
        self.reloader = DataModelReloader(for: self)
    }
    
    var displayOptions: Options = [.icon, .countDown, .popoverView] {
        didSet {
            self.updateMenuBarItemsVisibility()
        }
    }
    
    func stopAlarmMenuBarButtonButtonWasClicked(_ item: StopAlarmMenuBarButton) {
        NSApp.activate(ignoringOtherApps: true)
        self.alarmNotificationController.handleUserClickedStopAll()
    }
    
    func primaryMenuBarItemButtonWasClicked(_ item: PrimaryMenuBarItem) {
        self.logger.log("MenuBar button was clicked")
        
        if self.primaryMenuItem.isPopoverVisible {
            self.primaryMenuItem.isPopoverVisible = false
        } else if self.displayOptions.contains(.popoverView) {
            self.primaryMenuItem.isPopoverVisible = true
        }
    }
    
    func updateMenuBarItemsVisibility() {
        if self.displayOptions.contains(.icon) {
            self.primaryMenuItem.isVisible = true
            self.stopAlarmItem.isVisible = false;
        } else {
            self.primaryMenuItem.isVisible = false
            self.stopAlarmItem.isVisible = false;
        }
    }
    
    func showInMenuBar() {
        self.updateMenuBarItemsVisibility()
    }

    func dataModelDidReload(_ dataModel: DataModel) {
        if self.displayOptions.contains(.icon) {
            self.primaryMenuItem.startCountdown()
            
            self.stopAlarmItem.isVisible = self.alarmNotificationController.alarmsAreFiring
            
        } else {
            self.primaryMenuItem.stopCountdown()
        }
    }
}
