//
//  AppControllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation
import RoosterCore

//struct AppControllers {
//    let alarmNotificationController: AlarmNotificationController
//    let dataModelController: RCCalendarDataModelController
//    let userNotificationController: UserNotificationCenterController
//    let preferencesController: PreferencesController
//
//    let menuBarController: MenuBarController
//
//    let systemUtilities: SystemUtilities
//
//    #if targetEnvironment(macCatalyst)
//    let audioSessionController: AudioSessionController
//    let appKitPlugin: AppKitPluginController
//    #endif
//
//    static var instance = AppControllers()
//
//    init() {
//
//        #if targetEnvironment(macCatalyst)
//        let audioSessionController = AudioSessionController()
//        let appKitPlugin = AppKitPluginController()
//        self.appKitPlugin = appKitPlugin
//        self.audioSessionController = audioSessionController
//        #endif
//
//        let preferencesController = PreferencesController()
//        self.alarmNotificationController = AlarmNotificationController()
//        self.dataModelController = RCCalendarDataModelController(withDataModelStorage: DataModelStorage())
//        self.userNotificationController = UserNotificationCenterController(preferencesController: preferencesController)
//        self.preferencesController = preferencesController
//        self.menuBarController = MenuBarController()
//        self.systemUtilities = SystemUtilities()
//    }
//}
//
//protocol AppControllerAware {
//
//}
//
//extension AppControllerAware {
//    var alarmNotificationController: AlarmNotificationController {
//        return AppControllers.instance.alarmNotificationController
//    }
//
//    var dataModelController: RCCalendarDataModelController {
//        return AppControllers.instance.dataModelController
//    }
//
//    #if targetEnvironment(macCatalyst)
//    let appKitPlugin = AppKitPluginController()
//                var appKitPlugin: AppKitPluginController {
//        return AppControllers.instance.appKitPlugin
//    }
//
//    var audioSessionController: AudioSessionController {
//        return AppControllers.instance.audioSessionController
//    }
//    #endif
//
//    var userNotificationController: UserNotificationCenterController {
//        return AppControllers.instance.userNotificationController
//    }
//
//    var preferencesController: PreferencesController {
//        return AppControllers.instance.preferencesController
//    }
//
//    var menuBarController: MenuBarController {
//        return AppControllers.instance.menuBarController
//    }
//
//    var systemUtilities: SystemUtilities {
//        return AppControllers.instance.systemUtilities
//    }
//}

extension Controllers {
    static let preferencesController = PreferencesController()
    static let menuBarController = MenuBarController()
    
    static func setupRoosterCore() {
        AlarmNotification.setAlarmStartActionsFactory()
        
    }
}
