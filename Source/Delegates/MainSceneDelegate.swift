//
//  SceneDelegate.swift
//  UIKitForMacPlayground
//
//  Created by Noah Gilmore on 6/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import SwiftUI

extension UIWindow {
    var nsWindow: AnyObject? {
        guard let nsWindows = NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject] else { return nil }
        for nsWindow in nsWindows {
            let uiWindows = nsWindow.value(forKeyPath: "uiWindows") as? [UIWindow] ?? []
            if uiWindows.contains(self) {
                return nsWindow
            }
        }
        print("failed to get nsWindow")
        return nil
    }
    
    var nsFrame : CGRect? {
        get {
            if let nsWindow = self.nsWindow,
               let frame = nsWindow.value(forKey:"frame") as? CGRect {
             
                return frame;
            }
            return nil
        }
        
        set(newFrame) {
            if let nsWindow = self.nsWindow {
                nsWindow.setValue(newFrame, forKey:"frame")
            }
            
        }
            
    }
    
    func setFrameAndBecomeVisible(newFrame: CGRect, counter: Int = 0) {
        if let _ = self.nsWindow {
            self.nsFrame = newFrame
            self.makeKeyAndVisible()
            return
        }

        if counter < 5 {
            DispatchQueue.main.async {
                self.setFrameAndBecomeVisible(newFrame: newFrame, counter: counter + 1)
            }
        }
    }
}


class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    let userActivityKey = "com.apple.rooster.staterestore.main"
    let windowBoundsKey = "windowBounds"
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: LaunchingView())
        
        DispatchQueue.main.async {
            if let windowBoundsString = UserDefaults.standard.object(forKey: self.windowBoundsKey) as? String {
                let frame = NSRectFromString(windowBoundsString)
                window.makeKey()
                window.setFrameAndBecomeVisible(newFrame: frame)
                
                print("\(frame)")
            }
        }
        self.window = window
    }
    
    func didReceiveCalendarAccess() {
        if self.window != nil {
            let navController = UINavigationController(rootViewController: UIHostingController(rootView: ContentView()))
            self.window?.rootViewController = navController
        }
        
//        navController.navigationBar.prefersLargeTitles = true

    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        
        print("Hello")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func windowScene(_ windowScene: UIWindowScene,
                     didUpdate previousCoordinateSpace: UICoordinateSpace,
                     interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
                     traitCollection previousTraitCollection: UITraitCollection) {
        print("Old: \(previousCoordinateSpace.bounds), new: \(windowScene.coordinateSpace.bounds)")
        
        var frameStr = "nil"
        if let frame = self.window?.frame {
            frameStr = "\(frame)"
        }
        
        print("New frame: \(frameStr)")
    }
    
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        if let frame = self.window?.nsFrame {
            UserDefaults.standard.set(NSStringFromRect(frame), forKey: self.windowBoundsKey)
            UserDefaults.standard.synchronize()
    
            print("saved window frame: \(frame)")
        }
        return NSUserActivity(activityType: self.userActivityKey)

    }
/*
    func restore(from activity: NSUserActivity) {
        guard activity.activityType == Bundle.main.activityType,
            let text = activity.userInfo?[Key.text] as? String,
            let isEditing = activity.userInfo?[Key.isEditing] as? Bool
            else { return }
        
        self.text = text
        self.isEditing = isEditing
    }
    
    func store(in activity: NSUserActivity) {
        activity.addUserInfoEntries(from: [Key.text: text, Key.isEditing: isEditing])
    }
*/
    
}

//#if targetEnvironment(macCatalyst)
//    func addWindowSizeHandlerForMacOS() {
//        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { windowScene in
//            print("addWindowSizeHandlerForMacOS()")
//            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 800)
//            // windowScene.sizeRestrictions?.maximumSize = CGSize(width: 801, height: 1101)
//        }
//    }
//#endif

//if let scene = scene as? UIWindowScene {
//  scene.sizeRestrictions?.minimumSize =
//    CGSize(width: 768.0, height: 768.0)
//  scene.sizeRestrictions?.maximumSize =
//    CGSize(
//      width: CGFloat.greatestFiniteMagnitude,
//      height: CGFloat.greatestFiniteMagnitude
//    )
//}

//func windowScene(_ windowScene: UIWindowScene,
//  didUpdate previousCoordinateSpace: UICoordinateSpace,
//  interfaceOrientation previousInterfaceOrientation:
//  UIInterfaceOrientation,
//  traitCollection previousTraitCollection: UITraitCollection) {
//    NotificationCenter.default.post(
//      name: .WindowSizeChanged, object: nil)
//}
