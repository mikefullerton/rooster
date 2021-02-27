//
//  AlarmNotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public class AlarmNotificationController : Loggable, AlarmNotificationDelegate, DataModelAware {

    public static let AlarmsWillStartEvent = NSNotification.Name("AlarmsWillStartEvent")

    public static let AlarmsDidStopEvent = NSNotification.Name("AlarmsDidStopEvent")
    
    private var notifications: [AlarmNotification]
    
    private var dataModelReloader: DataModelReloader? = nil
 
    public init() {
        self.notifications = []
        self.dataModelReloader = DataModelReloader(for: self)
    }
    
    public func scheduleNotification(forItem item: RCCalendarItem) {
        if self.notifications.contains(where: { return $0.itemID == item.id }) {
            return
        }

        self.schedule(notification: AlarmNotification(withItemIdentifier: item.id))
    }
    
    public func schedule(notification: AlarmNotification) {

        let notify = self.notifications.count == 0
        self.notifications.append(notification)
        
        self.logger.log("Starting notification for \(notification)")
        
        notification.delegate = self
        notification.start()

        if notify {
            self.logger.log("Notifying that alarms will start")
            NotificationCenter.default.post(name: AlarmNotificationController.AlarmsWillStartEvent, object: self)
        }
    }

    public var alarmsAreFiring: Bool {
        return self.notifications.count > 0
    }
    
    private func notifyIfAlarmsStopped() {
        DispatchQueue.main.async {
            if self.notifications.count == 0 {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmNotificationController.AlarmsDidStopEvent, object: self)
                
                #if targetEnvironment(macCatalyst)
                Controllers.appKitPlugin.utilities.stopBouncingAppIcon()
                #endif

                #if os(macOS)
                Controllers.systemUtilities.stopBouncingAppIcon()
                #endif

                Controllers.userNotificationController.cancelAllNotifications()
            }
        }
    }
    
    public func stopNotification(forItem item: RCCalendarItem) {
        self.notifications.forEach() { (notification) in
            if notification.itemID == item.id {
                self.logger.log("Stopping alarm for: \(item.description)")
                notification.stop()
            }
        }
        
        self.notifyIfAlarmsStopped()
    }
    
    public func stopAllNotifications(bringNotificationAppsForward: Bool) {
        self.notifications.reversed().forEach() { (notification) in
            notification.stop()
            
            if bringNotificationAppsForward,
               let item = notification.item {
                item.bringLocationAppsToFront()
            }
        }
        
        Controllers.dataModelController.stopAllAlarms()
        
        self.notifyIfAlarmsStopped()
    }
    
    private func removeNotification(_ notificationToRemove: AlarmNotification) {
        for (index, notification) in self.notifications.reversed().enumerated() {
            if notification == notificationToRemove {
                self.notifications.remove(at: index)
                break
            }
        }
        self.notifyIfAlarmsStopped()
    }
    
    public func alarmNotificationDidStart(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did start: \(alarmNotification)")
    }
    
    public func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did stop: \(alarmNotification)")
        self.removeNotification(alarmNotification)
    }
    
    private func stopNotifications(forIdentifiersNotInSet identifiers: Set<String>) {
        self.notifications.reversed().forEach() { (notification) in
            if notification.shouldStop(ifNotContainedIn: identifiers) {
                self.logger.log("Stopping notification for \(notification.description)")
                
                notification.stop()
            }
        }
    }
    
    private func updateNotifications(forItems items: [RCCalendarItem]) {
        self.logger.log("Updating alarms for \(items.count) items")
        
        var startedCount = 0
        
        for item in items {
            if item.alarm.isFiring {
                startedCount += 1
                // this will do nothing if already firing
                self.scheduleNotification(forItem: item)
            } else {
                self.stopNotification(forItem: item)
            }
        }
        
        self.logger.log("Started alarms for \(startedCount) items")
    }
    
    public func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        self.logger.log("RCCalendarDataModel updated. Updating alarms, current alarm count: \(self.notifications.count)")
        
        let items:[RCCalendarItem] = Controllers.dataModelController.dataModel.events + Controllers.dataModelController.dataModel.reminders

        var itemsSet = Set<String>()
        items.forEach { (item) in
            itemsSet.insert(item.id)
        }
        
        self.stopNotifications(forIdentifiersNotInSet: itemsSet)
        
        self.updateNotifications(forItems: items)
    }
    
    public func handleUserClickedStopAll() {
        if self.alarmsAreFiring {
            self.stopAllNotifications(bringNotificationAppsForward: true)
        }
        
//        item.bringLocationAppsToFront()
    }
}

