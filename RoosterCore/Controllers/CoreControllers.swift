//
//  Controllers.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation

public class CoreControllers {
    public static let shared = CoreControllers()

    public let systemUtilities = SystemUtilities()
    public let userNotificationController = UserNotificationCenterController()
    public let scheduleController = ScheduleController(withSchedulingQueue: DispatchQueue.serial)
    public let alarmNotificationController = AlarmNotificationController()

    public func open() {
        self.alarmNotificationController.open()
    }
}
