//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import EventKit

class AppKitPluginController : NSObject, AppKitPluginProtocol {
    
    static var instance = AppKitPluginController()
    
    private var plugin: AppKitPluginProtocol?
    
    private override init() {
        self.plugin = AppKitPluginController.loadPlugin()
    }
    
    func requestPermissionToDelegateCalendars(for eventStore: EKEventStore, completion: ((Bool, EKEventStore?, Error?) -> Void)?) {
        self.plugin?.requestPermissionToDelegateCalendars(for: eventStore, completion:completion)
    }
    
    func bringAppToFront() {
        self.plugin?.bringAppToFront()
    }
 
    func bringAnotherApp(toFront bundleIdentier: String) {
        self.plugin?.bringAnotherApp(toFront: bundleIdentier)
    }
    
    func openURLDirectly(inAppIfPossible url: URL, completion: ((Bool, Error?) -> Void)? = nil) {
        self.plugin?.openURLDirectly(inAppIfPossible: url, completion: completion)
    }
    
    static func loadPlugin() -> AppKitPluginProtocol? {
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
    
        guard let plugin = principleClass.init() as? AppKitPluginProtocol else {
            print("Failed to initialize plugin: \(principleClass)")
            return nil
        }
        
        return plugin
    }

    var menuBarPopover: MenuBarPopoverProtocol? {
        return self.plugin?.menuBarPopover
    }
    
    
}

