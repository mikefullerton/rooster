//
//  MenuBarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
#if targetEnvironment(macCatalyst)

class MenuBarPopoverController : NSObject, AppKitMenuBarControllerDelegate {
   
    
    static var instance = MenuBarPopoverController()
    
    var popover: AppKitMenuBarController? {
        return AppKitPluginController.instance.menuBarPopover
    }
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStart(_:)), name: AlarmController.AlarmsWillStartEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStop(_:)), name: AlarmController.AlarmsDidStopEvent, object: nil)
    }

    @objc private func alarmsDidStart(_ notif: Notification) {
        self.popover?.alarmStateDidChange()
    }
    
    @objc private func alarmsDidStop(_ notif: Notification) {
        self.popover?.alarmStateDidChange()
    }
    
    func appKitMenuBarControllerAreAlarmsFiring(_ controller: AppKitMenuBarController) -> Bool {
        return AlarmController.instance.alarmsAreFiring
    }
    
    public var isPopoverHidden: Bool {
        get {
            return self.popover == nil ? true : self.popover!.isPopoverHidden
        }
        set(hidden) {
            self.popover?.isPopoverHidden = hidden
        }
    }
    
    func showIconInMenuBar() {
        self.popover?.delegate = self
        self.popover?.showIconInMenuBar()
    }
    
    func menuBarButtonWasClicked(_ popover: AppKitMenuBarController) {
        
        if AlarmController.instance.alarmsAreFiring {
            AlarmController.instance.stopAllAlarms()
        } else {
            AppKitPluginController.instance.utilities.bringAppToFront()
            // show popover
        }
        
//        self.isPopoverHidden = !self.isPopoverHidden
    }
}
#endif
