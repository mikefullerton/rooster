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
class AppDelegate: UIResponder, UIApplicationDelegate, AppKitInstallationUpdaterDelegate {
    
    static var instance: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    enum UserActivities: String {
        case preferences = "com.apple.rooster.preferences"
        case main = "com.apple.rooster.main"
        case update = "com.apple.rooster.update"
    }
    
    enum SceneNames: String {
        case preferences = "preferences"
        case main = "main"
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationController.instance.requestAccess()
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

    private var preferencesMenuItem : UIMenu {
        let preferencesCommand = UICommand(title: "Preferences…",
                                    image: nil,
                                    action: #selector(self.showPreferences(_:)),
                                    propertyList: nil)

        return UIMenu(title: "",
                      image: nil,
                      identifier: UIMenu.Identifier(UserActivities.preferences.rawValue),
                      options: [ UIMenu.Options.displayInline ],
                      children: [ preferencesCommand ])
    }
    
    @objc private func showPreferences(_ sender: AppDelegate) {
        self.showPreferences()
    }
    
    private var updateMenuItem : UIMenu {
        let command = UICommand(title: "Check for Updates",
                                image: nil,
                                action: #selector(self.checkForUpdates(_:)),
                                propertyList: nil)

        return UIMenu(title: "",
                          image: nil,
                          identifier: UIMenu.Identifier(UserActivities.update.rawValue),
                          options: [ UIMenu.Options.displayInline ],
                          children: [ command ])
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let preferencesMenuItem = self.preferencesMenuItem
        builder.insertSibling(preferencesMenuItem, afterMenu: .about)
        
        let updateMenuItem = self.updateMenuItem
        builder.insertSibling(updateMenuItem, afterMenu: preferencesMenuItem.identifier)
        
    }
    
    func showPreferences () {
        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }

    @objc private func checkForUpdates(_ sender: AppDelegate) {
        AppKitPluginController.instance.installationUpdater.checkForUpdates()
    }

    func appKitInstallationUpdater(_ updater: AppKitInstallationUpdater, didCheckForUpdate updateAvailable: Bool, error: Error?) {
        
    }
    
    public func mainWindowDidShow() {
        AlarmController.instance.start()
        MenuBarPopoverController.instance.showIconInMenuBar()
        AppKitPluginController.instance.installationUpdater.delegate = self
        AppKitPluginController.instance.installationUpdater.configure(withAppBundle: Bundle.init(for: type(of:self)))
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


