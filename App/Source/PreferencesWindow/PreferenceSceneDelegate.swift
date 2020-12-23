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
        
        guard let scene = (scene as? UIWindowScene) else { return }
     
        scene.sizeRestrictions?.minimumSize = CGSize(width: 320, height: 500.0)
        scene.sizeRestrictions?.maximumSize = CGSize(
          width: CGFloat.greatestFiniteMagnitude,
          height: CGFloat.greatestFiniteMagnitude
        )
        
        let window = UIWindow(windowScene: scene)
//        let viewController = UIHostingController(rootView: MainView().environmentObject(EventKitDataModel.instance))
        let viewController = PreferencesViewController()
        window.rootViewController = viewController
        
        self.set(window: window, restoreKey: "")
    }
}


