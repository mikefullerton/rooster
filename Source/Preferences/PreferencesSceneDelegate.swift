//
//  SquareSceneDelegate.swift
//  UIKitForMacPlayground
//
//  Created by Noah Gilmore on 7/14/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class PreferencesSceneDelegate: WindowSceneDelegate, Reloadable {
    
    private var reloader: AuthenticationReloader?
 
    override init() {
        super.init()
        self.reloader = AuthenticationReloader(for: self)
    }
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }

        scene.sizeRestrictions?.minimumSize = CGSize(width: 400, height: 800.0)
        scene.sizeRestrictions?.maximumSize = CGSize(
          width: 400,
          height: 800
        )
        
        scene.title = "Rooster Preferences"
        
        print("calenderData: \(AppController.instance.calendarData)")
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = UIHostingController(rootView: PreferencesView().environmentObject(AppController.instance.calendarData))
        
        // "preferencesWindowBounds"
        self.set(window: window, restoreKey:nil)
    }
    
    func reload() {
//        self.window?.rootViewController = UIHostingController(rootView: PreferencesView().environmentObject(AppController.instance.calendarData))
//
    }
    

}
