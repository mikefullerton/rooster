//
//  AlarmNotificationController.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/24/20.
//

import Foundation

public protocol AlarmNotificationControllerDelegate: AnyObject {
    func alarmNotificationControllerAlarmsDidUpdate(_ controller: AlarmNotificationController)
    func alarmNotificationController(_ controller: AlarmNotificationController, alarmNotificationDidStart alarm: AlarmNotification)
    func alarmNotificationController(_ controller: AlarmNotificationController, alarmNotificationDidFinish alarm: AlarmNotification)
}

public class AlarmNotificationController: Loggable {
    public static let AlarmsWillStartEvent = Notification.Name("AlarmsWillStartEvent")

    public static let AlarmsDidStopEvent = Notification.Name("AlarmsDidStopEvent")

    private let notifier = DeferredCallback()

    public weak var delegate: AlarmNotificationControllerDelegate?

    public private(set) var notifications: [AlarmNotification] = [] {
        didSet {
            if oldValue != self.notifications {
                self.delegate?.alarmNotificationControllerAlarmsDidUpdate(self)
                self.notifyAllAlarmsStoppedIfNeeded()
            }
        }
    }

    private let nextAlarmTimer = SimpleTimer(withName: "NextAlarmTimer")

    private var alarmStates: [String: AlarmState] = [:]

    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    public init() {
    }

    internal func open() {
        self.scheduleUpdateHandler.handler = { oldSchedule, newSchedule in
            self.scheduleDidUpdate(oldSchedule, newSchedule)
        }
    }

    public func notificationIsFiring(forItemID itemID: String) -> Bool {
        self.notifications.contains { $0.itemID == itemID }
    }

    public func notification(forItemID itemID: String) -> AlarmNotification? {
        if let index = self.notifications.firstIndex(where: { $0.itemID == itemID }) {
            return self.notifications[index]
        }

        return nil
    }

    public var alarmsAreFiring: Bool {
        !self.notifications.isEmpty
    }

    public var notificationsCount: Int {
        self.notifications.count
    }

    // FUTURE: decouple bringing apps forward
    public func stopAllNotifications(bringNotificationAppsForward: Bool) {
        let notifications = self.notifications
        self.notifications = []

        var scheduleItems: [ScheduleItem] = []

        notifications.forEach { notif in
            if let scheduleItem = notif.scheduleItem {
                scheduleItems.append(scheduleItem)
            } else {
                assertionFailure("schedule item is nil!")
            }

            notif.stop()

            // this is weird, I don't like this here.
            if bringNotificationAppsForward {
                notif.bringLocationAppsForward()
            }
        }

        let updatedScheduleItems = self.finishFiringScheduleAlarms(scheduleItems)
        CoreControllers.shared.scheduleController.update(scheduleItems: updatedScheduleItems) { [weak self] success, _, error in
            guard let self = self else { return }

            guard success else {
                self.logger.error("updating schedule items failed stopping alarms: \(String(describing: error))")
                return
            }
            self.logger.log("updated \(updatedScheduleItems.count) schedule items ok")
        }
    }
}

extension AlarmNotificationController {
    public func scheduleDidUpdate(_ schedule: Schedule, _ oldSchedule: Schedule) {
        self.updateNotifications(forSchedule: schedule)
    }
}

extension AlarmNotificationController: AlarmNotificationDelegate {
    public func alarmNotificationDidStart(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did start: \(alarmNotification)")
        self.delegate?.alarmNotificationController(self, alarmNotificationDidStart: alarmNotification)
    }

    public func alarmNotificationDidFinish(_ alarmNotification: AlarmNotification) {
        self.logger.log("AlarmNotification did stop: \(alarmNotification)")
        self.delegate?.alarmNotificationController(self, alarmNotificationDidFinish: alarmNotification)
    }

    public func alarmNotification(_ alarmNotification: AlarmNotification,
                                  didUpdateState state: AlarmNotificationController.AlarmState) {
        self.alarmStates[alarmNotification.itemID] = state
    }
}

extension AlarmNotificationController {
    fileprivate func updateNotifications(forSchedule schedule: Schedule) {
        self.logger.log("Schedule updated. Updating alarms -- current alarm count: \(self.notifications.count)")

        self.stopOrphanedNotifications(forScheduleItems: schedule.items)

        let items = self.finishScheduleItemAlarmsIfNeeded(schedule.items)
        self.updateNotificationsIfNeeded(withScheduleItems: items)

        self.startTimerForNextEventTime()
    }

    fileprivate func stopOrphanedNotifications(forScheduleItems items: [ScheduleItem]) {
        var newNotifs: [AlarmNotification] = []

        let itemsSet = Set<String>(items.map { $0.scheduleItemID })

        self.notifications.forEach { notification in
            if !itemsSet.contains(notification.itemID) {
                self.logger.log("Stopping orphaned notification for \(notification.description)")
                notification.stop()
            } else {
                newNotifs.append(notification)
            }
        }

        self.notifications = newNotifs
    }

    fileprivate func stopAlarmIfFiring(forItemID itemID: String) -> Bool {
        if let index = self.notifications.firstIndex(where: { $0.itemID == itemID }) {
            let notif = self.notifications[index]
            self.notifications.remove(at: index)
            self.logger.log("Stopping alarm for: \(notif.description)")
            notif.stop()
            return true
        }

        return false
    }

    fileprivate func startAlarmIfNotFiring(forItemID itemID: String) -> Bool {
        guard !self.notifications.contains(where: { $0.itemID == itemID }) else {
            return false
        }

        let cachedState = self.alarmStates[itemID] ?? .zero
        let notification = AlarmNotification(withItemIdentifier: itemID, alarmState: cachedState)
        let shouldNotify = self.notifications.isEmpty

        self.notifications.append(notification)

        self.logger.log("Starting notification for \(notification)")

        notification.delegate = self
        notification.start()

        if shouldNotify {
            self.logger.log("Notifying that alarms will start")
            NotificationCenter.default.post(name: AlarmNotificationController.AlarmsWillStartEvent, object: self)
        }

        return true
    }

    fileprivate func updateNotificationsIfNeeded(withScheduleItems items: [ScheduleItem]) {
        self.logger.log("Updating alarms for \(items.count) items")

        var startedCount = 0
        var stoppedCount = 0

        for item in items {
            let itemID = item.scheduleItemID

            guard let alarm = item.alarm else {
                if self.stopAlarmIfFiring(forItemID: itemID) {
                    stoppedCount += 1
                }
                continue
            }

            if self.notificationIsFiring(forItemID: itemID) == alarm.isFiring {
                continue
            }

            if alarm.isFiring {
                if self.startAlarmIfNotFiring(forItemID: itemID) {
                    self.logger.log("Starting alarm for: \(item.description)")
                    startedCount += 1
                }
            } else if self.stopAlarmIfFiring(forItemID: itemID) {
                stoppedCount += 1
            } else {
                assertionFailure("couldn't start or stop alarm")
            }
        }

        self.logger.log("Started alarms for \(startedCount) items, Stopped alarms for \(stoppedCount) alarms")
    }

    fileprivate func finishFiringScheduleAlarms(_ items: [ScheduleItem]) -> [ScheduleItem] {
        var outList = items

        for index in 0..<outList.count {
            guard var alarm = outList[index].alarm else {
                continue
            }

            if  alarm.isFiring {
                alarm.isFinished = true
                outList[index].alarm = alarm
            }
        }

        return outList
    }

    fileprivate func finishScheduleItemAlarmsIfNeeded(_ items: [ScheduleItem]) -> [ScheduleItem] {
        var outList = items

        for index in 0..<outList.count {
            guard var alarm = outList[index].alarm else {
                continue
            }

            if  alarm.needsFinishing {
                alarm.isFinished = true
                outList[index].alarm = alarm
            }
        }

        if !Schedule.scheduleItemsAreEqual(outList, items) {
            CoreControllers.shared.scheduleController.update(scheduleItems: outList)
        }

        return outList
    }

    fileprivate func startTimerForNextEventTime() {
        self.nextAlarmTimer.stop()

        var nextAlarmTime = CoreControllers.shared.scheduleController.schedule.nextAlarmDateForSchedulingTimer

        if nextAlarmTime == nil {
            nextAlarmTime = Date.midnightToday
        }

        if nextAlarmTime!.isEqualToOrBeforeDate(Date()) {
            self.logger.error("got bad next fire date: \(nextAlarmTime!.shortDateAndLongTimeString)")
            return
        }

        self.logger.log("scheduling next alarm update for: \(nextAlarmTime!.shortDateAndTimeString)")
        self.nextAlarmTimer.start(withDate: nextAlarmTime!) { [weak self] timer in
            guard let self = self else { return }

            self.logger.log("""
                next alarm date timer did fire after: \(timer.timeInterval), \
                scheduled for: \(nextAlarmTime!.shortDateAndTimeString)
                """)

            self.updateNotifications(forSchedule: CoreControllers.shared.scheduleController.schedule)

            self.notifier.schedule {
                CoreControllers.shared.scheduleController.reload()
            }
        }
    }

    fileprivate func notifyAllAlarmsStoppedIfNeeded() {
        self.notifier.schedule {
            if self.notifications.isEmpty {
                self.logger.log("Notifying that all alarms have stopped")
                NotificationCenter.default.post(name: AlarmNotificationController.AlarmsDidStopEvent, object: self)
            }
        }
    }
}

extension AlarmNotificationController {
    public struct AlarmState: DescribeableOptionSet {
        public typealias RawValue = Int

        public private(set) var rawValue: Int

        public static var zero = AlarmState([])

        // state
        public static var started                   = AlarmState(rawValue: 1 << 1)
        public static var finished                  = AlarmState(rawValue: 1 << 2)

        public static let soundsStarted             = AlarmState(rawValue: 1 << 3)
        public static let soundsFinished            = AlarmState(rawValue: 1 << 4)
        public static let notificationsStarted      = AlarmState(rawValue: 1 << 5)
        public static let notificationsFinished     = AlarmState(rawValue: 1 << 6)

        public static let aborted                   = AlarmState(rawValue: 1 << 7)

        public static let all: AlarmState = [
            .started,
            .finished,
            .soundsStarted,
            .soundsFinished,
            .notificationsStarted,
            .notificationsFinished,
            .aborted
        ]

        public static var descriptions: [(Self, String)] = [
            (.started, "started"),
            (.finished, "finished"),
            (.aborted, "aborted"),
            (.soundsStarted, "soundStarted"),
            (.soundsFinished, "soundsFinished"),
            (.notificationsStarted, "notificationsStarted"),
            (.notificationsFinished, "notificationsFinished")
        ]

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}
