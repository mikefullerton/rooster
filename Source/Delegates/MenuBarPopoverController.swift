//
//  MenuBarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation

class MenuBarPopoverController : NSObject, MenuBarPopoverProtocolDelegate {
    
    static var instance = MenuBarPopoverController()
    
    var popover: MenuBarPopoverProtocol? {
        return AppKitPlugin.instance.menuBarPopover
    }
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStart(_:)), name: AlarmController.AlarmsDidStartEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStop(_:)), name: AlarmController.AlarmsDidStopEvent, object: nil)
    }

    @objc private func alarmsDidStart(_ notif: Notification) {
        self.popover?.isAlarmFiring = true
    }
    
    @objc private func alarmsDidStop(_ notif: Notification) {
        self.popover?.isAlarmFiring = false
    }
    
    public var isPopoverHidden: Bool {
        get {
            return self.popover == nil ? true : self.popover!.isPopoverHidden
        }
        set(hidden) {
            self.popover?.isPopoverHidden = hidden
        }
    }
    
    func showInMenuBar() {
        self.popover?.delegate = self
        self.popover?.showInMenuBar()
    }
    
    func menuBarButtonWasClicked(_ popover: MenuBarPopoverProtocol) {
        
        if AlarmController.instance.alarmsAreFiring {
            AlarmController.instance.stopAllAlarms()
        } else {
            AppKitPlugin.instance.bringAppToFront()
            // show popover
        }
        
//        self.isPopoverHidden = !self.isPopoverHidden
    }
}
