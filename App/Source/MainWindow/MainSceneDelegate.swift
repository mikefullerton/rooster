//
//  MainSceneDelegate.m
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import UIKit

class MainSceneDelegate: WindowSceneDelegate, MainViewControllerDelegate {
        
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let viewController = MainViewController()
        
        let _ = viewController.view // make sure it's loaded
        
//        windowScene.sizeRestrictions?.minimumSize = viewController.minimumContentSize
//        windowScene.sizeRestrictions?.maximumSize = CGSize(
//          width: CGFloat.greatestFiniteMagnitude,
//          height: CGFloat.greatestFiniteMagnitude
//        )
        
        let window = UIWindow(windowScene: windowScene)
        viewController.delegate = self
        window.rootViewController = viewController
        
        self.set(window: window, restoreKey: "mainWindowBounds", initialWindowSize: viewController.preferredContentSize)
        
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
       
    func mainViewController(_ viewController: MainViewController, preferredContentSizeDidChange size: CGSize) {
        self.setWindowSize(size)
    }
}

