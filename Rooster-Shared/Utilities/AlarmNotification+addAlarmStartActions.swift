//
//  AlarmStartActions.swift
//  RoosterCoreTests
//
//  Created by Mike Fullerton on 2/27/21.
//

import Foundation
import RoosterCore

extension AlarmNotification {
    public static func setAlarmStartActionsFactory() {
        Self.actionsFactoryBlock = {
            [
                StartNotificationAlarmAction(),
                StartPlayingSoundAlarmAction()
            ]
        }
    }
}
