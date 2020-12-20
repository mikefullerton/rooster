//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import EventKit

class AppKitPluginController : NSObject, RoosterAppKitPlugin {
    
    static var instance = AppKitPluginController()
    
    private var plugin: RoosterAppKitPlugin?
    
    private override init() {
        self.plugin = AppKitPluginController.loadPlugin()
    }
    
    static func loadPlugin() -> RoosterAppKitPlugin? {
        let pluginPath = Bundle.main.builtInPlugInsPath!.appending("/RoosterAppKitPlugin.bundle")
        guard let bundle = Bundle(path: pluginPath) else {
            print("Unable to load plugin bundle at path: \(pluginPath)")
            return nil
        }
        
        guard let principleClass = bundle.principalClass as? NSObject.Type else {
            print("Failed to get principle class for plugin")
            return nil
        }
        
        print("Loaded plugin principle class: \(principleClass)")
    
        guard let plugin = principleClass.init() as? RoosterAppKitPlugin else {
            print("Failed to initialize plugin: \(principleClass)")
            return nil
        }
        
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

    
}

