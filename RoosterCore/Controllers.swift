//
//  Controllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

public struct Controllers {
    
    private init() {
        
    }
    
    public static var alarmNotificationController = AlarmNotificationController()
    public static var dataModelController = RCCalendarDataModelController(withDataModelStorage: DataModelStorage())
    public static var systemUtilities = SystemUtilities()
    public static var userNotificationController = UserNotificationCenterController()
}

