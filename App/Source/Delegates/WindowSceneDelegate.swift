//
//  WindowSceneDelegate.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/16/20.
//

import Foundation
import UIKit

class WindowSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var windowRestoreKey: String;
    
    override init() {
        self.windowRestoreKey = ""
        self.window = nil
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowSceneDidBecomeVisible(_:)),
                                               name: NSNotification.Name("_UIWindowSceneDidBecomeVisibleNotification"),
                                               object: window)
        
    }
    
    func set(window: UIWindow, restoreKey: String) {
        self.window = window
        self.windowRestoreKey = restoreKey
        self.window?.makeKeyAndVisible()
    }
    
    @objc func windowSceneDidBecomeVisible(_ notif: Notification) {
        AppKitPluginController.instance.windowController.restoreWindowPosition(forWindow: (self.window as Any),
                                                                               windowName: self.windowRestoreKey)
    }

    
}
