//
//  AppDelegate.swift
//  Rooster (macOS)
//
//  Created by Mike Fullerton on 11/14/20.
//

import Foundation
import UIKit
import SwiftUI
#if targetEnvironment(macCatalyst)
protocol MacAppDelegateProtocols : AppKitInstallationUpdaterDelegate {}
#else
protocol MacAppDelegateProtocols {}
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MacAppDelegateProtocols {

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

    
    func showPreferences () {
        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }

    #if targetEnvironment(macCatalyst)

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

    @objc private func checkForUpdates(_ sender: AppDelegate) {
        AppKitPluginController.instance.installationUpdater.checkForUpdates()
    }

    func appKitInstallationUpdater(_ updater: AppKitInstallationUpdater, didCheckForUpdate updateAvailable: Bool, error: Error?) {
        
    }
    #endif
    
    public func mainWindowDidShow() {
        AlarmController.instance.start()
        #if targetEnvironment(macCatalyst)
        MenuBarPopoverController.instance.showIconInMenuBar()
        AppKitPluginController.instance.installationUpdater.delegate = self
        AppKitPluginController.instance.installationUpdater.configure(withAppBundle: Bundle.init(for: type(of:self)))
        #endif
    }
}


