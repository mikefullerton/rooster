//
//  AlarmNotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

class AlarmNotificationController : Loggable, AlarmNotificationDelegate, DataModelAware {

    public static let AlarmsWillStartEvent = NSNotification.Name("AlarmsWillStartEvent")

    public static let AlarmsDidStopEvent = NSNotification.Name("AlarmsDidStopEvent")
    
    private var notifications: [AlarmNotification]
    
    private var dataModelReloader: DataModelReloader? = nil
 
    init() {
        self.notifications = []
        self.dataModelReloader = DataModelReloader(for: self)
    }
    
    func scheduleNotification(forItem item: CalendarItem) {
        if self.notifications.contains(where: { return $0.itemID == item.id }) {
            return
        }

        self.schedule(notification: AlarmNotification(withItemIdentifier: item.id))
    }
    
    func schedule(notification: AlarmNotification) {

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

    var alarmsAreFiring: Bool {
        return self.notifications.count > 0
    }
    
    private func notifyIfAlarmsStopped() {
        DispatchQueue.main.async {
            if self.notifications.count == 0 {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmNotificationController.AlarmsDidStopEvent, object: self)
                
                #if targetEnvironment(macCatalyst)
                AppDelegate.instance.appKitPlugin.utilities.stopBouncingAppIcon()
                #endif

                #if os(macOS)
                AppDelegate.instance.systemUtilities.stopBouncingAppIcon()
                #endif

                AppDelegate.instance.userNotificationController.cancelAllNotifications()
            }
        }
    }
    
    func stopNotification(forItem item: CalendarItem) {
        self.notifications.forEach() { (notification) in
            if notification.itemID == item.id {
                self.logger.log("Stopping alarm for: \(item.description)")
                notification.stop()
            }
        }
        
        self.notifyIfAlarmsStopped()
    }
    
    func stopAllNotifications(bringNotificationAppsForward: Bool) {
        self.notifications.reversed().forEach() { (notification) in
            notification.stop()
            
            if bringNotificationAppsForward,
               let item = notification.item {
                item.bringLocationAppsToFront()
            }
        }
        
        AppDelegate.instance.dataModelController.stopAllAlarms()
        
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
    
    func alarmNotificationDidStart(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did start: \(alarmNotification)")
    }
    
    func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did stop: \(alarmNotification)")
        self.removeNotification(alarmNotification)
    }
    
    func stopNotifications(forIdentifiersNotInSet identifiers: Set<String>) {
        self.notifications.reversed().forEach() { (notification) in
            if notification.shouldStop(ifNotContainedIn: identifiers) {
                self.logger.log("Stopping notification for \(notification.description)")
                
                notification.stop()
            }
        }
    }
    
    private func updateNotifications(forItems items: [CalendarItem]) {
        self.logger.log("Updating alarms for \(items.count) items")
        
        var startedCount = 0
        
        for item in items {
            if item.alarm.state == .firing {
                startedCount += 1
                // this will do nothing if already firing
                self.scheduleNotification(forItem: item)
            } else {
                self.stopNotification(forItem: item)
            }
        }
        
        self.logger.log("Started alarms for \(startedCount) items")
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.logger.log("DataModel updated. Updating alarms, current alarm count: \(self.notifications.count)")
        
        let items:[CalendarItem] = AppDelegate.instance.dataModelController.dataModel.events + AppDelegate.instance.dataModelController.dataModel.reminders

        var itemsSet = Set<String>()
        items.forEach { (item) in
            itemsSet.insert(item.id)
        }
        
        self.stopNotifications(forIdentifiersNotInSet: itemsSet)
        
        self.updateNotifications(forItems: items)
    }
    
    func handleUserClickedStopAll() {
        if self.alarmsAreFiring {
            self.stopAllNotifications(bringNotificationAppsForward: true)
        }
        
//        item.bringLocationAppsToFront()
    }
}

