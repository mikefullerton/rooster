//
//  SceneDelegate.swift
//  UIKitForMacPlayground
//
//  Created by Noah Gilmore on 6/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import SwiftUI


class MainSceneDelegate: WindowSceneDelegate {

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
     
        scene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 200.0)
        scene.sizeRestrictions?.maximumSize = CGSize(
          width: CGFloat.greatestFiniteMagnitude,
          height: CGFloat.greatestFiniteMagnitude
        )
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: LaunchingView())
        self.set(window: window, restoreKey: "mainWindowBounds")
    }
    
    func didReceiveCalendarAccess() {
        if self.window != nil {
            let data = AppController.instance.calendarManager.data
            let viewController = UIHostingController(rootView: ContentView().environmentObject(data))
            self.window?.rootViewController = viewController
        }
    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
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

