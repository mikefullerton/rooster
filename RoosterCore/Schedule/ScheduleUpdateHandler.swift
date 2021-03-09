//
//  EventKitDataModelUpdateHandler.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

public class ScheduleUpdateHandler {
    public typealias HandlerBlock = (_ newSchedule: Schedule, _ oldSchedule: Schedule) -> Void

    public var handler: HandlerBlock?

    public init(withHandler handler: HandlerBlock? = nil) {
        self.handler = handler
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: ScheduleController.scheduleDidChangeEvent,
                                               object: nil)
    }

    @objc private func notificationReceived(_ notif: Notification) {
        if  let oldSchedule = notif.oldSchedule, let newSchedule = notif.newSchedule {
            self.handler?(newSchedule, oldSchedule)
        }
    }
}
