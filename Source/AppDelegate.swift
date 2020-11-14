//
//  AppDelegate.swift
//  Rooster (macOS)
//
//  Created by Mike Fullerton on 11/14/20.
//

import Foundation
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    enum UserActivities: String {
        case preferences = "com.apple.rooster.preferences"
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CalendarManager.instance.requestAccess()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if let activity = options.userActivities.first {
            if activity.activityType == UserActivities.preferences.rawValue {
                let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
                configuration.delegateClass = PreferencesSceneDelegate.self
                return configuration
            }
        }

        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = DefaultSceneDelegate.self
        return configuration
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let preferencesCommand = UICommand(title: "Preferences…",
                                    image: nil,
                                    action: #selector(self.showPreferences(_:)),
                                    propertyList: nil)
        
        let preferencesMenu = UIMenu(title: "",
                                     image: nil,
                                     identifier: UIMenu.Identifier("com.apple.rooster.preferences"),
                                     options: [ UIMenu.Options.displayInline ],
                                     children: [ preferencesCommand ])
                
        builder.insertSibling(preferencesMenu, afterMenu: .about)
    }
    
    func showPreferences () {
        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }
    
    @objc private func showPreferences(_ sender: AppDelegate) {
        self.showPreferences()
    }

}


