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
    let appKitPlugin: AppKitPluginController
    let audioSessionController: AudioSessionController
    let userNotificationController: UserNotificationCenterController
    let preferencesController: PreferencesController

    static var instance = AppControllers()
    
    init() {
        let preferencesController = PreferencesController()
        let alarmNotificationController = AlarmNotificationController()
        let dataModelController = DataModelController(withDataModelStorage: DataModelStorage())
        let appKitPlugin = AppKitPluginController()
        let audioSessionController = AudioSessionController()
        let userNotificationController = UserNotificationCenterController(preferencesController: preferencesController)

        self.alarmNotificationController = alarmNotificationController
        self.dataModelController = dataModelController
        self.appKitPlugin = appKitPlugin
        self.audioSessionController = audioSessionController
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
    
    var appKitPlugin: AppKitPluginController {
        return AppControllers.instance.appKitPlugin
    }
    
    var audioSessionController: AudioSessionController {
        return AppControllers.instance.audioSessionController
    }
    
    var userNotificationController: UserNotificationCenterController {
        return AppControllers.instance.userNotificationController
    }
    
    var preferencesController: PreferencesController {
        return AppControllers.instance.preferencesController
    }
}
