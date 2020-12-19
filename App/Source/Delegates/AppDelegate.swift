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
    
    var menuBarPopover = MenuBarPopover()
    
    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    enum UserActivities: String {
        case preferences = "com.apple.rooster.preferences"
        case main = "com.apple.rooster.main"
    }
    
    enum SceneNames: String {
        case preferences = "preferences"
        case main = "main"
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AlarmController.instance.start()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if  let activity = options.userActivities.first {
            if activity.activityType == UserActivities.preferences.rawValue {
                let configuration = UISceneConfiguration(name: UserActivities.preferences.rawValue, sessionRole: connectingSceneSession.role)
                configuration.delegateClass = PreferencesSceneDelegate.self
                return configuration
            }
        }

        let configuration = UISceneConfiguration(name: UserActivities.main.rawValue, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = MainSceneDelegate.self
        return configuration
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let preferencesCommand = UICommand(title: "Preferences…",
                                    image: nil,
                                    action: #selector(self.showPreferences(_:)),
                                    propertyList: nil)

        let calendarPreferencesMenu = UIMenu(title: "",
                                     image: nil,
                                     identifier: UIMenu.Identifier(UserActivities.preferences.rawValue),
                                     options: [ UIMenu.Options.displayInline ],
                                     children: [ preferencesCommand ])

        builder.insertSibling(calendarPreferencesMenu, afterMenu: .about)
    }
    
    func showPreferences () {
        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }

    @objc private func showPreferences(_ sender: AppDelegate) {
        self.showPreferences()
    }
    
//    func findMainScene() -> MainSceneDelegate? {
//        let connectedSessions = UIApplication.shared.openSessions
//        for session in connectedSessions {
//            if let mainSceneDelegate = session.scene?.delegate as? MainSceneDelegate {
//                return mainSceneDelegate
//            }
//        }
//
//        return nil
//    }
//
//    func findViewController(inWindow window: UIWindow) -> UIViewController? {
//        if let rootViewController = window.rootViewController {
//            if let navigationController = rootViewController as? UINavigationController {
//                return navigationController.viewControllers.first
//            }
//            if let tabBarController = rootViewController as? UITabBarController {
//                return tabBarController.selectedViewController
//            }
//            return rootViewController
//        }
//
//        return nil
//    }
//
//    func findViewControllerForAlert() -> UIViewController? {
//        let connectedSessions = UIApplication.shared.openSessions
//        for session in connectedSessions {
//            if let windowScene = session.scene as? UIWindowScene {
//                if windowScene.title == SceneNames.main.rawValue {
//                    let windows = windowScene.windows
//                    for window in windows {
//                        if let viewController = self.findViewController(inWindow: window) {
//                            return viewController
//                        }
//                    }
//                }
//            }
//        }
//
//        let windows = UIApplication.shared.windows
//
//        for window in windows {
//            if window.isKeyWindow {
//                return self.findViewController(inWindow: windows[0])
//            }
//        }
//
//
//        return nil
//    }
    

    
}


