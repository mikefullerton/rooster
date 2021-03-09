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
    public static var systemUtilities = SystemUtilities()
    public static var userNotificationController = UserNotificationCenterController()
    
    // data model
    
    // low level
    public static var dataModelStorage = DataModelStorage()
    public static var eventKitController = EKController(withDataModelStorage: Self.dataModelStorage)
    
    // app should interact with these
    
    public static var reminders = RemindersController()
    public static var events = EventsController()
    public static var calendar = CalendarsController()

    public static var dataModel = RCCalendarDataModelController(withEventKitController: Self.eventKitController)
}

