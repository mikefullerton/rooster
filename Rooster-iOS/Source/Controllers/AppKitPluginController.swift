//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//
#if targetEnvironment(macCatalyst)

import Foundation
import EventKit

/// interface to the AppKitPlugin
class AppKitPluginController : NSObject, RoosterAppKitPlugin, Loggable, AppKitMenuBarControllerDelegate {
    private var plugin: RoosterAppKitPlugin?
    
    override init() {
        self.plugin = AppKitPluginController.loadPlugin()
        super.init()
        
        self.menuBarPopover.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStart(_:)), name: AlarmNotificationController.AlarmsWillStartEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(alarmsDidStop(_:)), name: AlarmNotificationController.AlarmsDidStopEvent, object: nil)
    }
    
    static func loadPlugin() -> RoosterAppKitPlugin? {
        let pluginPath = Bundle.main.builtInPlugInsPath!.appending("/RoosterAppKitPlugin.bundle")
        guard let bundle = Bundle(path: pluginPath) else {
            self.logger.fault("Unable to load plugin bundle at path: \(pluginPath)")
            return nil
        }
        
        guard let principleClass = bundle.principalClass as? NSObject.Type else {
            self.logger.fault("Failed to get principle class for plugin")
            return nil
        }
        
        self.logger.log("Loaded plugin principle class: \(principleClass)")
    
        guard let plugin = principleClass.init() as? RoosterAppKitPlugin else {
            self.logger.fault("Failed to initialize plugin: \(principleClass)")
            return nil
        }
        
        self.logger.log("AppKit plugin loaded ok")
    
        return plugin
    }

    var menuBarPopover: AppKitMenuBarController {
        return self.plugin!.menuBarPopover
    }
    
    var eventKitHelper : AppKitEventKitHelper {
        return self.plugin!.eventKitHelper
    }

    var utilities : AppKitUtilities {
        return self.plugin!.utilities
    }
    
    var installationUpdater: AppKitInstallationUpdater {
        return self.plugin!.installationUpdater
    }

    var windowController: AppKitWindowController {
        return self.plugin!.windowController
    }
    
    @objc private func alarmsDidStart(_ notif: Notification) {
        self.menuBarPopover.alarmStateDidChange()
    }
    
    @objc private func alarmsDidStop(_ notif: Notification) {
        self.menuBarPopover.alarmStateDidChange()
    }

    func appKitMenuBarControllerAreAlarmsFiring(_ controller: AppKitMenuBarController) -> Bool {
        return Controllers.alarmNotificationController.alarmsAreFiring
    }
    
    func menuBarButtonWasClicked(_ popover: AppKitMenuBarController) {
        Controllers.alarmNotificationController.handleUserClickedStopAll()
    }

    func appKitMenuBarControllerNextFireDate(_ controller: AppKitMenuBarController) -> Date? {
        return Controllers.dataModel.dataModel.nextAlarmDate
    }
}

#endif
