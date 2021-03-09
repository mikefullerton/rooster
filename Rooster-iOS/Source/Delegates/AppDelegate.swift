//
//  AppDelegate.swift
//  Rooster (macOS)
//
//  Created by Mike Fullerton on 11/14/20.
//

import Foundation
import SwiftUI
import UIKit
#if targetEnvironment(macCatalyst)
protocol MacAppDelegateProtocols: AppKitInstallationUpdaterDelegate {}
#else
protocol MacAppDelegateProtocols {}
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MacAppDelegateProtocols, Loggable {
    enum UserActivities: String {
        case main = "com.commapps.rooster.main"
        case update = "com.commapps.rooster.update"
        case fileRadar = "com.commapps.rooster.file-radar"
        case openRepo = "com.commapps.rooster.open-repo"
    }

    enum SceneNames: String {
//        case preferences = "preferences"
        case main = "main"
    }

    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static var instance: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.logger.log("Application did finish launching")

        self.audioSessionController.startAudioSession()
        self.userNotificationController.requestAccess()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: UserActivities.main.rawValue, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = MainSceneDelegate.self
        return configuration
    }

    #if targetEnvironment(macCatalyst)

    private lazy var infoUrl: URL? = {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("About/about.html")
        }

        return nil
    }()

    @objc func showHelp(_ sender: Any?) {
        if let url = self.infoUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private var updateMenuItem: UIMenu {
        let command = UICommand(title: "CHECK_FOR_UPDATES".localized,
                                image: nil,
                                action: #selector(self.checkForUpdates(_:)),
                                propertyList: nil)

        return UIMenu(title: "",
                          image: nil,
                          identifier: UIMenu.Identifier(UserActivities.update.rawValue),
                          options: [ UIMenu.Options.displayInline ],
                          children: [ command ])
    }

    @objc private func fileRadar(_ sender: AppDelegate) {
        //        rdar://new/problem/componentid=1188232

        UIApplication.shared.open(URL(string: "rdar://new/problem/componentid=1188232")!,
                                  options: [:],
                                  completionHandler: nil)
    }

    @objc private func openRepoURL(_ sender: AppDelegate) {
        UIApplication.shared.open(URL(string: "https://stashweb.sd.apple.com/users/mfullerton/repos/rooster")!,
                                  options: [:],
                                  completionHandler: nil)
    }

    private var fileRadarMenuItem: UIMenu {
        let command = UICommand(title: "FILE_RADAR".localized,
                                image: nil,
                                action: #selector(self.fileRadar(_:)),
                                propertyList: nil)

        return UIMenu(title: "",
                          image: nil,
                          identifier: UIMenu.Identifier(UserActivities.fileRadar.rawValue),
                          options: [ UIMenu.Options.displayInline ],
                          children: [ command ])
    }

    private var openRepoMenuItem: UIMenu {
        let command = UICommand(title: "VIEW_CODE_MENU_ITEM".localized,
                                image: nil,
                                action: #selector(self.openRepoURL(_:)),
                                propertyList: nil)

        return UIMenu(title: "",
                          image: nil,
                          identifier: UIMenu.Identifier(UserActivities.openRepo.rawValue),
                          options: [ UIMenu.Options.displayInline ],
                          children: [ command ])
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        let updateMenuItem = self.updateMenuItem
        builder.insertSibling(updateMenuItem, afterMenu: .about)

        let fileRadar = self.fileRadarMenuItem
        builder.insertChild(fileRadar, atEndOfMenu: .help)

        let openRepo = self.openRepoMenuItem
        builder.insertChild(openRepo, atEndOfMenu: .help)
    }

    @objc private func checkForUpdates(_ sender: AppDelegate) {
        self.appKitPlugin.installationUpdater.checkForUpdates()
    }

    func appKitInstallationUpdater(_ updater: AppKitInstallationUpdater, didCheckForUpdate updateAvailable: Bool, error: Error?) {
    }
    #endif

    public func didAuthenticate() {
        self.logger.log("Application authenticate EventKit access")

        #if targetEnvironment(macCatalyst)
        self.appKitPlugin.menuBarPopover.showIconInMenuBar()
        self.appKitPlugin.installationUpdater.delegate = self
        self.appKitPlugin.installationUpdater.configure(withAppBundle: Bundle(for: \(type(of: self))))
        #endif

        FirstRunController().handleFirstRunIfNeeded()

        NotificationCenter.default.post(name: AppDelegate.CalendarDidAuthenticateEvent, object: self)
    }

    public func mainWindowDidShow() {
        self.logger.log("Main Window did show")

        self.dataModelController.authenticate { _ in
            DispatchQueue.main.async {
                self.didAuthenticate()
            }
        }
    }
}

//        let preferencesMenuItem = self.preferencesMenuItem
//        builder.insertSibling(preferencesMenuItem, afterMenu: .about)

// @objc private func showPreferences(_ sender: AppDelegate) {
//    self.showPreferences()
// }

// func showPreferences () {
//
//        for window in UIApplication.shared.windows {
//            if window.windowScene?.title == "Preferences" {
//
//                // Catalyst is extremely lame with window management
//                Controllers.appKitPlugin.windowController.bringWindow(toFront: window)
//
//                return
//            }
//        }
//
//        let activity = NSUserActivity(activityType: UserActivities.preferences.rawValue)
//        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil, errorHandler: nil)
// }

//    private var preferencesMenuItem : UIMenu {
//        let preferencesCommand = UICommand(title: "Preferences…",
//                                    image: nil,
//                                    action: #selector(self.showPreferences(_:)),
//                                    propertyList: nil)
//
//        return UIMenu(title: "",
//                      image: nil,
//                      identifier: UIMenu.Identifier(UserActivities.preferences.rawValue),
//                      options: [ UIMenu.Options.displayInline ],
//                      children: [ preferencesCommand ])
//    }

//    func applicationWillTerminate(_ application: UIApplication) {
//
//        let windows = UIApplication.shared.windows
//
//        var session: UISceneSession?
//
//        for window in windows {
//            if let scene = window.windowScene,
//               scene.title == "Preferences" {
//
//                session = scene.session
//                break
//            }
//        }
//
//        if session != nil {
//            let options =  UIWindowSceneDestructionRequestOptions()
//            options.windowDismissalAnimation = .standard
//
//            UIApplication.shared.requestSceneSessionDestruction(session!,
//                                                                options: options) { error in
//
//            }
//        }
//
//    }

//        if  let activity = options.userActivities.first {
//            if activity.activityType == UserActivities.preferences.rawValue {
//                let configuration = UISceneConfiguration(name: UserActivities.preferences.rawValue, sessionRole: connectingSceneSession.role)
//                configuration.delegateClass = PreferencesSceneDelegate.self
//                return configuration
//            }
//        }
