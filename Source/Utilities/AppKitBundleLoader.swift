//
//  AppKitBundleLoader.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation

struct AppKitBundleLoader {
    func load() -> AppKitPluginProtocol? {
        let pluginPath = Bundle.main.builtInPlugInsPath!.appending("/RoosterAppKitPlugin.bundle")
        if let bundle = Bundle(path: pluginPath) {
            
            if let principleClass = bundle.principalClass as? NSObject.Type {
                print("\(String(describing: principleClass))")

                if let plugin = principleClass.init() as? AppKitPluginProtocol {
                    return plugin;
                }
            }
        }
    
        return nil
    }
    
    
}
