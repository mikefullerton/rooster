//
//  SceneDelegate.swift
//  UIKitForMacPlayground
//
//  Created by Noah Gilmore on 6/27/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

class PreferencesSceneDelegate: WindowSceneDelegate {

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
     
        
        if EventKitDataModelController.instance.isAuthenticated {
        
            let viewController = PreferencesViewController()
//            var size = viewController.calculatedSize
            let size = CGSize(width: 450, height: 700)
    
//            scene.sizeRestrictions?.minimumSize = size
            scene.sizeRestrictions?.maximumSize = size
            scene.title = "Preferences"
            let window = UIWindow(windowScene: scene)
            window.rootViewController = viewController
            self.set(window: window, restoreKey: "")
        }
    }
}


