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
    private(set) var initialWindowSize = CGSize.zero
    
    override init() {
        self.windowRestoreKey = ""
        self.window = nil
        super.init()
        
        #if targetEnvironment(macCatalyst)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowSceneDidBecomeVisible(_:)),
                                               name: NSNotification.Name("_UIWindowSceneDidBecomeVisibleNotification"),
                                               object: window)
        #endif
        
    }
    
    func set(window: UIWindow, restoreKey: String, initialWindowSize: CGSize) {
        self.window = window
        self.windowRestoreKey = restoreKey
        self.initialWindowSize = initialWindowSize
        self.window?.makeKeyAndVisible()
    }
    
    #if targetEnvironment(macCatalyst)
    
    func setWindowSize(_ size: CGSize){
        self.appKitPlugin.windowController.setContentSize(size, forWindow: window as Any)
    }
    
    @objc func windowSceneDidBecomeVisible(_ notif: Notification) {
        
        if let fromWindow = notif.object as? UIWindow,
           fromWindow == self.window {

            Controllers.appKitPlugin.windowController.restoreWindowPosition(forWindow: (self.window as Any),
                                                                     windowName: self.windowRestoreKey,
                                                                     initialSize: self.initialWindowSize)
        }
    }

    #endif
    
}
