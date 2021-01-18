//
//  MainSceneDelegate.m
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import UIKit

class MainSceneDelegate: WindowSceneDelegate, MainViewControllerDelegate {
        
    lazy var mainViewController = MainViewController()
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        let viewController = self.mainViewController
        
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
            
        DispatchQueue.main.async {
            AppDelegate.instance.mainWindowDidShow()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalenderAuthentication(_:)), name: AppDelegate.CalendarDidAuthenticateEvent, object: nil)
    }
       
    func mainViewController(_ viewController: MainViewController, preferredContentSizeDidChange size: CGSize) {
        self.setWindowSize(size)
    }

    @objc func handleCalenderAuthentication(_ notif: Notification) {
        #if targetEnvironment(macCatalyst)
        
        if let window = self.window,
           let windowScene = window.windowScene {
            let viewController = self.mainViewController
            let toolbar = viewController.toolbar
            if let titlebar = windowScene.titlebar {
                titlebar.separatorStyle = .line
                titlebar.toolbar = toolbar
                titlebar.toolbarStyle = .unified
            }
        }
        #endif

    }
}

