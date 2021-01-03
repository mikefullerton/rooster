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
    
    static let instance = AlarmNotificationController()

    private var notifications: [AlarmNotification]
    
    private var dataModelReloader: DataModelReloader?
    
    private init() {
        self.notifications = []
        self.dataModelReloader = nil
    }
    
    func start() {
        self.dataModelReloader = DataModelReloader(for: self)
    }
    
    func scheduleNotification(forItem item: EventKitItem) {
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
            }
        }
    }
    
    func stopNotification(forItem item: EventKitItem) {
        self.notifications.forEach() { (notification) in
            if notification.itemID == item.id {
                self.logger.log("Stopping alarm for: \(item.description)")
                notification.stop()
            }
        }
        
        self.notifyIfAlarmsStopped()
    }
    
    func stopAllNotifications() {
        self.notifications.reversed().forEach() { (notification) in
            notification.stop()
        }

        UserNotificationCenterController.instance.cancelNotifications()
        #if targetEnvironment(macCatalyst)
        AppKitPluginController.instance.utilities.stopBouncingAppIcon()
        #endif
        
        EventKitDataModelController.instance.stopAllAlarms()
        
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
    
    private func updateNotifications(forItems items: [EventKitItem]) {
        for item in items {
            if item.alarm.state == .firing {
                // this will do nothing if already firing
                AlarmNotificationController.instance.scheduleNotification(forItem: item)
            } else {
                AlarmNotificationController.instance.stopNotification(forItem: item)
            }
        }
    }
    
    func dataModelDidReload(_ dataModel: EventKitDataModel) {

        self.logger.log("Updating alarms for \(self.notifications.count)")
        
        let items:[EventKitItem] = EventKitDataModelController.dataModel.events + EventKitDataModelController.dataModel.reminders

        var itemsSet = Set<String>()
        items.forEach { (item) in
            itemsSet.insert(item.id)
        }
        
        self.stopNotifications(forIdentifiersNotInSet: itemsSet)
        
        self.updateNotifications(forItems: items)
    }
}

