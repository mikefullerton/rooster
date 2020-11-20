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
class AppDelegate: UIResponder, UIApplicationDelegate, AlarmControllerDelegate {
    
    var appKitBundle: AppKitPluginProtocol?
    
    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    enum UserActivities: String {
        case calendarPreferences = "com.apple.rooster.calendar-preferences"
        case main = "com.apple.rooster.main"
    }
    
    enum SceneNames: String {
        case calendarPreferences = "calendarPreferences"
        case main = "main"
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let bundleLoader = AppKitBundleLoader()
        self.appKitBundle = bundleLoader.load()
        AppController.instance.delegate = self;
        AppController.instance.start()
        
        return true
    }

    var hasLaunched: Bool = false
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        if self.hasLaunched {
            if  let activity = options.userActivities.first {
                if activity.activityType == UserActivities.calendarPreferences.rawValue {
                    let configuration = UISceneConfiguration(name: UserActivities.calendarPreferences.rawValue, sessionRole: connectingSceneSession.role)
                    configuration.delegateClass = CalendarPreferencesSceneDelegate.self
                    return configuration
                }
            }
        }

        self.hasLaunched = true

        let configuration = UISceneConfiguration(name: UserActivities.main.rawValue, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = MainSceneDelegate.self
        return configuration
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let preferencesCommand = UICommand(title: "Calendars…",
                                    image: nil,
                                    action: #selector(self.showCalendarPreferences(_:)),
                                    propertyList: nil)
        
        let calendarPreferencesMenu = UIMenu(title: "",
                                     image: nil,
                                     identifier: UIMenu.Identifier(UserActivities.calendarPreferences.rawValue),
                                     options: [ UIMenu.Options.displayInline ],
                                     children: [ preferencesCommand ])
                
        builder.insertSibling(calendarPreferencesMenu, afterMenu: .about)
    }
    
    func showCalendarPreferences () {
        let activity = NSUserActivity(activityType: UserActivities.calendarPreferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }
    
    @objc private func showCalendarPreferences(_ sender: AppDelegate) {
        self.showCalendarPreferences()
    }
    
    func findMainScene() -> MainSceneDelegate? {
        let connectedSessions = UIApplication.shared.openSessions
        for session in connectedSessions {
            if let mainSceneDelegate = session.scene?.delegate as? MainSceneDelegate {
                return mainSceneDelegate
            }
        }
        
        return nil
    }
    
    func findViewController(inWindow window: UIWindow) -> UIViewController? {
        if let rootViewController = window.rootViewController {
            if let navigationController = rootViewController as? UINavigationController {
                return navigationController.viewControllers.first
            }
            if let tabBarController = rootViewController as? UITabBarController {
                return tabBarController.selectedViewController
            }
            return rootViewController
        }
        
        return nil
    }
    
    func findViewControllerForAlert() -> UIViewController? {
        let connectedSessions = UIApplication.shared.openSessions
        for session in connectedSessions {
            if let windowScene = session.scene as? UIWindowScene {
                if windowScene.title == SceneNames.main.rawValue {
                    let windows = windowScene.windows
                    for window in windows {
                        if let viewController = self.findViewController(inWindow: window) {
                            return viewController
                        }
                    }
                }
            }
        }
        
        let windows = UIApplication.shared.windows
        
        for window in windows {
            if window.isKeyWindow {
                return self.findViewController(inWindow: windows[0])
            }
        }
        
        
        return nil
    }
    
    func alarmControllerDidRequestCalendarAccess(_ alarmController: AppController, success: Bool, error: Error?) {
        if success {
            if let mainSceneDelegate = self.findMainScene() {
                mainSceneDelegate.didReceiveCalendarAccess()
            }
        } else {
            if let viewController = self.findViewControllerForAlert() {
                let alertController = UIAlertController(title: "Failed to recieve permission to access calendars", message: "We can't do anything, we we will quit now", preferredStyle: UIAlertController.Style.alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    exit(0)
                }))
                
                viewController.present(alertController, animated: true)
            }
        }
    }
    
}


