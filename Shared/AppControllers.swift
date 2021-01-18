//
//  AppControllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation

struct AppControllers {
    let alarmNotificationController: AlarmNotificationController
    let dataModelController: DataModelController
    let userNotificationController: UserNotificationCenterController
    let preferencesController: PreferencesController

    #if targetEnvironment(macCatalyst)
    let audioSessionController: AudioSessionController
    let appKitPlugin: AppKitPluginController
    #endif
    
    static var instance = AppControllers()
    
    init() {
        let preferencesController = PreferencesController()
        let alarmNotificationController = AlarmNotificationController()
        let dataModelController = DataModelController(withDataModelStorage: DataModelStorage())
        let userNotificationController = UserNotificationCenterController(preferencesController: preferencesController)

        #if targetEnvironment(macCatalyst)
        let audioSessionController = AudioSessionController()
        let appKitPlugin = AppKitPluginController()
        self.appKitPlugin = appKitPlugin
        self.audioSessionController = audioSessionController
        #endif
        
        self.alarmNotificationController = alarmNotificationController
        self.dataModelController = dataModelController
        self.userNotificationController = userNotificationController
        self.preferencesController = preferencesController
    }
}

protocol AppControllerAware {
    
}

extension AppControllerAware {
    var alarmNotificationController: AlarmNotificationController {
        return AppControllers.instance.alarmNotificationController
    }
    
    var dataModelController: DataModelController {
        return AppControllers.instance.dataModelController
    }
    
    #if targetEnvironment(macCatalyst)
    let appKitPlugin = AppKitPluginController()
                var appKitPlugin: AppKitPluginController {
        return AppControllers.instance.appKitPlugin
    }
    
    var audioSessionController: AudioSessionController {
        return AppControllers.instance.audioSessionController
    }
    #endif
    
    var userNotificationController: UserNotificationCenterController {
        return AppControllers.instance.userNotificationController
    }
    
    var preferencesController: PreferencesController {
        return AppControllers.instance.preferencesController
    }
}
