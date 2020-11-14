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

    enum UserActivities: String {
        case preferences = "com.apple.rooster.preferences"
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CalendarManager.instance.requestAccess()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

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

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
    
    @objc private func showPreferences(_ sender: AppDelegate) {
//        guard let delegate = UIApplication.shared.connectedScenes.compactMap({
//            ($0 as? UIWindowScene)
//        }).filter({ $0.activationState == .foregroundActive })
//            .first?.delegate else { return }
//        guard let sceneDelegate = delegate as? SceneDelegate else { return }
//        
//        sceneDelegate.showPreferences()
        
        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
    }

}


