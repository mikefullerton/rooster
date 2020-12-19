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
    var windowBoundsKey: String?
    
    func set(window: UIWindow, restoreKey: String?) {
        self.window = window
        self.windowBoundsKey = restoreKey

        #if targetEnvironment(macCatalyst)
        if self.windowBoundsKey != nil {
            DispatchQueue.main.async {
                if  let key = self.windowBoundsKey,
                    let windowBoundsString = UserDefaults.standard.object(forKey: key) as? String {
                    let frame = NSRectFromString(windowBoundsString)
                    window.makeKey()
                    window.setFrameAndBecomeVisible(newFrame: frame)
                    
//                    print("restored window frame: \(frame) for key: \(key)")
                }
            }
        } else {
            self.window?.makeKeyAndVisible()
        }
        #else
        self.window?.makeKeyAndVisible()
        #endif
    }
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        #if targetEnvironment(macCatalyst)
        if  let key = self.windowBoundsKey,
            let frame = self.window?.nsFrame {
            UserDefaults.standard.set(NSStringFromRect(frame), forKey: key)
            UserDefaults.standard.synchronize()
    
//            print("saved window frame: \(frame), for key: \(key)")
        }
        #endif
        return nil
    }

    
}
