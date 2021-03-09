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
    
    private var notifications: [AlarmNotification] = []
    
    private var dataModelReloader = DataModelReloader()
 
    private let nextAlarmTimer = SimpleTimer(withName: "NextAlarmTimer")

    private var alarmStates:[String: AlarmState] = [:]
    
    public init() {
        self.dataModelReloader.target = self
    }
    
    public func notificationInProgress(forItemID itemID: String) -> Bool {
        return self.notifications.contains(where: { return $0.itemID == itemID })
    }
    
    public func startNotifications(forItemID itemID: String) {
        if self.notificationInProgress(forItemID: itemID) {
            return
        }

        let cachedState = self.alarmStates[itemID] ?? .zero
        
        self.schedule(notification: AlarmNotification(withItemIdentifier: itemID, alarmState: cachedState))
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
    
    private func notifyAllAlarmsStoppedIfNeeded() {
        DispatchQueue.main.async {
            if self.notifications.count == 0 {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmNotificationController.AlarmsDidStopEvent, object: self)
            }
        }
    }
    
    public func stopNotifications(forItemID itemID: String) {
        
        var newNotifs:[AlarmNotification] = []
        
        self.notifications.forEach() { (notification) in
            if notification.itemID == itemID {
                self.logger.log("Stopping alarm for: \(notification.calendarItem?.description ?? "nil")")
                notification.stop()
            } else {
                newNotifs.append(notification)
            }
        }
        
        self.notifications = newNotifs
        
        self.notifyAllAlarmsStoppedIfNeeded()
    }
    
    public func stopAllNotifications(bringNotificationAppsForward: Bool) {
        self.notifications.reversed().forEach() { (notification) in
            notification.stop()
        
            // this is weird, I don't like this here.
            if bringNotificationAppsForward {
                notification.bringLocationAppsForward()
            }
        }
        
        self.notifications = []
        
        Controllers.alarmNotificationController.stopAllAlarms()
        
        self.notifyAllAlarmsStoppedIfNeeded()
    }
    
    private func removeNotification(_ notificationToRemove: AlarmNotification) {
        for (index, notification) in self.notifications.reversed().enumerated() {
            if notification == notificationToRemove {
                self.notifications.remove(at: index)
                break
            }
        }
        self.notifyAllAlarmsStoppedIfNeeded()
    }
    
    public func alarmNotificationDidStart(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did start: \(alarmNotification)")
    }
    
    public func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did stop: \(alarmNotification)")
    }
    
    public func alarmNotification(_ alarmNotification: AlarmNotification, didUpdateState state: AlarmNotificationController.AlarmState) {
        
        self.alarmStates[alarmNotification.itemID] = state
    }
    
    private func stopNotifications(forIdentifiersNotInSet identifiers: Set<String>) {
        
        var newNotifs:[AlarmNotification] = []
        
        self.notifications.forEach() { (notification) in
            if notification.shouldStop(ifNotContainedIn: identifiers) {
                self.logger.log("Stopping notification for \(notification.description)")
                
                notification.stop()
            } else {
                newNotifs.append(notification)
            }
        }
        
        self.notifications = newNotifs
    }
    
    private func updateNotifications(forItems items: [RCCalendarItem]) {
        self.logger.log("Updating alarms for \(items.count) items")
        
        var startedCount = 0
        
        for item in items {
            if item.alarm.needsStarting {
                startedCount += 1
                self.startNotifications(forItemID: item.id)
            } else if item.alarm.needsFinishing {
                self.stopNotifications(forItemID: item.id)
            }
        }
        
        self.logger.log("Started alarms for \(startedCount) items")
    }
    
    public func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        self.logger.log("RCCalendarDataModel updated. Updating alarms, current alarm count: \(self.notifications.count)")
        
        let items:[RCCalendarItem] = dataModel.events + dataModel.reminders

        var itemsSet = Set<String>()
        items.forEach { (item) in
            itemsSet.insert(item.id)
        }
        
        self.stopNotifications(forIdentifiersNotInSet: itemsSet)
        
        self.updateAlarmsIfNeeded()
        self.updateNotifications(forItems: items)
        self.stopNotificationsIfNeeded()
        self.startTimerForNextEventTime()
    }
    
    public func handleUserClickedStopAll() {
        if self.alarmsAreFiring {
            self.stopAllNotifications(bringNotificationAppsForward: true)
        }
        
//        item.bringLocationAppsToFront()
    }
    
    private func updateAlarms<T>(forItems items: [T]) -> [T]? where T: RCCalendarItem {
        var outList:[T] = []
        var madeChange = false

        for item in items {
            
            var mutableItem = item
            
            if mutableItem.alarm.needsFinishing {
                mutableItem.alarm.isFinished = true
                outList.append(mutableItem)
                madeChange = true
            } else if mutableItem.alarm.needsFinishReset {
                mutableItem.alarm.isFinished = false
                outList.append(mutableItem)
                madeChange = true
            } else {
                outList.append(item)
            }
        }

        return madeChange ? outList : nil
    }

    private func stopNotificationsIfNeeded() {
        
        var newNotifs:[AlarmNotification] = []
        
        for notification in self.notifications {
            if let calendarItem = notification.calendarItem {
                if !calendarItem.alarm.isHappeningNow ||
                    calendarItem.alarm.isFinished {
                    notification.stop()
                } else {
                    newNotifs.append(notification)
                }
            }
        }

        self.notifications = newNotifs
        self.notifyAllAlarmsStoppedIfNeeded()
    }
    
    private func updateAlarmsIfNeeded() {
        if let events = Controllers.dataModelController.dataModel?.events,
            let updatedEvents = self.updateAlarms(forItems: events)  {
            Controllers.dataModelController.update(someEvents: updatedEvents)
            self.logger.log("Updated alarms for \(updatedEvents.count) events")
        }

        if  let reminders = Controllers.dataModelController.dataModel?.reminders,
            let updatedReminders = self.updateAlarms(forItems: reminders) {
            Controllers.dataModelController.update(someReminders: updatedReminders)
            self.logger.log("Updated alarms for \(updatedReminders.count) events")
        }
    }
    
    private func startTimerForNextEventTime() {
        self.nextAlarmTimer.stop()
        
        if  let dataModel = Controllers.dataModelController.dataModel,
            let nextAlarmTime = dataModel.nextAlarmDateForSchedulingTimer {
        
            self.logger.log("scheduling next alarm update for: \(nextAlarmTime.shortDateAndTimeString)")
            self.nextAlarmTimer.start(withDate: nextAlarmTime) { [weak self] (timer) in
                self?.logger.log("next alarm date timer did fire after: \(timer.timeInterval), scheduled for: \(nextAlarmTime.shortDateAndTimeString)")
                
                self?.updateAlarmsIfNeeded()
                
                Controllers.dataModelController.reloadData()
                
            }
        }
    }
    
    public func stopAllAlarms() {
        
        if  let events = Controllers.dataModelController.dataModel?.events,
            let updatedEvents = self.finishAlarms(forItems: events)  {
            Controllers.dataModelController.update(someEvents: updatedEvents)
        }

        if  let reminders = Controllers.dataModelController.dataModel?.reminders,
            let updatedReminders = self.finishAlarms(forItems: reminders) {
            Controllers.dataModelController.update(someReminders: updatedReminders)
        }
    }
    
    private func finishAlarms<T>(forItems items: [T]) -> [T]? where T: RCCalendarItem {
        var outList:[T] = []
        var madeChange = false
        
        for item in items {
            
            var alarm = item.alarm
            
            if  alarm.isFiring {
                alarm.isFinished = true
                
                var updatedItem = item
                updatedItem.alarm = alarm
                outList.append(updatedItem)
                
                madeChange = true
            } else {
                outList.append(item)
            }
        }
        
        return madeChange ? outList : nil
    }
    
    

}

extension RCCalendarItem {
    public mutating func stopAlarmButtonClicked() {
        self.alarm.isFinished = !self.alarm.isFinished
        Controllers.dataModelController.update(calendarItem: self)
    }
}

extension AlarmNotificationController {
    
//    public var hasExpired: Bool {
//        if !self.canExpire && self.isInThePast {
//            return true
//        }
//
//        return false
//    }
//
//    // MARK: -
//
//    public mutating func updateState(_ state: State, to value: Bool) {
//        if value {
//            self.state.insert( state)
//        } else {
//            self.state.remove(state)
//        }
//    }
//
//    public mutating func setStarted() {
//        if self.willFire {
//            self.resetState()
//            self.state.insert(.started)
//        }
//    }
//
//    public mutating func resetState() {
//        self.state.remove(.allState)
//        self.finishedDates = nil
//    }
//
//    public mutating func setFinished() {
//        if !self.isFinished {
//            self.state.insert(.finished)
//
//            self.finishedDates = FinishedDates(finishedDate: Date(),
//                                               alarmStartDate: self.startDate,
//                                               alarmEndDate: self.endDate)
//        }
//    }
//
//    public var hasStarted: Bool {
//        return self.state.contains(.started)
//    }
//
//    public var isFinished: Bool {
//        return self.state.contains( .finished )
//    }
//
//    public var soundsStarted: Bool {
//        get {
//            return self.state.contains( .soundsStarted )
//        }
//        set(value) {
//            self.updateState(.soundsStarted, to: value)
//        }
//    }
//
//    public var soundsFinished: Bool {
//        get {
//            return self.state.contains( .soundsFinished )
//        }
//        set(value) {
//            self.updateState(.soundsFinished, to: value)
//        }
//    }
//
//    public var notificationsStarted: Bool {
//        get {
//            return self.state.contains( .notificationsStarted )
//        }
//        set(value) {
//            self.updateState(.notificationsStarted, to: value )
//        }
//    }
//
//    public var notificationsFinished: Bool {
//        get {
//            return self.state.contains( .notificationsFinished )
//        }
//        set(value) {
//            self.updateState(.notificationsFinished, to: value )
//        }
//    }

    
    public struct AlarmState: DescribeableOptionSet {
     
        public typealias RawValue = Int

        public private(set) var rawValue: Int
        
        public static var zero                      = AlarmState([])
        
        // state
        public static var started                   = AlarmState(rawValue: 1 << 1)
        public static var finished                  = AlarmState(rawValue: 1 << 2)

        public static let soundsStarted             = AlarmState(rawValue: 1 << 3)
        public static let soundsFinished            = AlarmState(rawValue: 1 << 4)
        public static let notificationsStarted      = AlarmState(rawValue: 1 << 5)
        public static let notificationsFinished     = AlarmState(rawValue: 1 << 6)

        public static let aborted                   = AlarmState(rawValue: 1 << 7)

        
        public static let all:AlarmState            = [ .started,
                                                        .finished,
                                                        .soundsStarted,
                                                        .soundsFinished,
                                                        .notificationsStarted,
                                                        .notificationsFinished,
                                                        .aborted ]

       
        public static var descriptions: [(Self, String)] = [
            (.started,                              "started"),
            (.finished,                             "finished"),
            (.aborted,                              "aborted"),
            (.soundsStarted,                        "soundStarted"),
            (.soundsFinished,                       "soundsFinished"),
            (.notificationsStarted,                 "notificationsStarted"),
            (.notificationsFinished,                "notificationsFinished"),
        ]
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
      
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
