//
//  MainSceneDelegate.m
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import UIKit

class MainSceneDelegate: WindowSceneDelegate {

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
     
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 200.0)
        windowScene.sizeRestrictions?.maximumSize = CGSize(
          width: CGFloat.greatestFiniteMagnitude,
          height: CGFloat.greatestFiniteMagnitude
        )
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = MainViewController()
        window.rootViewController = viewController
        
        self.set(window: window, restoreKey: "mainWindowBounds")
        
        #if targetEnvironment(macCatalyst)
        let toolbar = viewController.toolbar
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .automatic
        }
        #endif
        
        DispatchQueue.main.async {
            AppDelegate.instance.mainWindowDidShow()
        }
    }
}

