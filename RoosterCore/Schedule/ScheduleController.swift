//
//  ScheduleController.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/30/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

// swiftlint:disable file_length closure_body_length
// swiftlint:disable cyclomatic_complexity

public protocol ScheduleControllerBehaviorProvider: AnyObject {
    func scheduleControllerScheduleBehavior(_ controller: ScheduleController) -> ScheduleBehavior
}

public class ScheduleController: Loggable {
    fileprivate var notifier = DeferredCallback()
    fileprivate lazy var storage = ScheduleStorage(withSchedulingQueue: self.schedulingQueue)
    fileprivate var isOpen = false
    fileprivate let schedulingQueue: DispatchQueue
    fileprivate let factory = Schedule.Factory()
    // public

    public private(set) weak var scheduleBehaviorProvider: ScheduleControllerBehaviorProvider?

    public static let scheduleDidChangeEvent = Notification.Name("ScheduleDidChangeEvent")
    public static let scheduleDidResetEvent = Notification.Name("ScheduleDidResetEvent")

    public static let newScheduleKey = "NewScheduleKey"
    public static let oldScheduleKey = "OldScheduleKey"

    private var dispatchQueue = DispatchQueue(label: "rooster.schedule.queue")

    private var eventKitDataModel = EventKitDataModel()

    internal lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        operationQueue.name = "rooster.scheduleOperationQueue"
        operationQueue.underlyingQueue = self.dispatchQueue
        return operationQueue
    }()

    public lazy var eventKitDataModelController: EventKitDataModelController = {
        let controller = EventKitDataModelController(withSchedulingQueue: self.schedulingQueue)
        controller.delegate = self
        return controller
    }()

    public var scheduleBehavior: ScheduleBehavior? {
        self.scheduleBehaviorProvider?.scheduleControllerScheduleBehavior(self)
    }

    public private(set) var schedule = Schedule() {
        didSet {
            if oldValue != self.schedule {
                self.operationQueue.addOperation {
                    self.notify(newSchedule: self.schedule, oldSchedule: oldValue)
                }
            }
        }
    }

    public init(withSchedulingQueue schedulingQueue: DispatchQueue) {
        self.schedulingQueue = schedulingQueue
    }

    public func requestAccessToCalendars(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.eventKitDataModelController.requestAccessToCalendars(completion: completion)
    }
}

extension ScheduleController {
     public func reload(completion: ((_ success: Bool, _ schedule: Schedule?, _ error: Error? ) -> Void)? = nil) {
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            self.logger.log("Starting eventKitDataModel reload operation...")

            guard let scheduleBehavior = self.scheduleBehavior else {
                self.logger.error("schedule behavior is nil")
                return
            }

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            self.actuallyReload(scheduleBehavior: scheduleBehavior) { success, newSchedule, error in
                defer { dispatchGroup.leave() }
                completion?(success, newSchedule, error)
            }

            dispatchGroup.wait()
            self.logger.log("Exited reload operation")
        }
    }

    public func reset(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            guard let scheduleBehavior = self.scheduleBehavior else {
                self.logger.error("schedule behavior is nil")
                return
            }

            self.logger.log("Starting reset operation")

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            self.actuallyReset(scheduleBehavior: scheduleBehavior) { success, error in
                defer { dispatchGroup.leave() }
                completion(success, error)
            }

            dispatchGroup.wait()

            self.logger.log("Exited reset operation")
        }
    }

    public func open(withScheduleBehaviorProvider scheduleBehaviorProvider: ScheduleControllerBehaviorProvider,
                     completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.scheduleBehaviorProvider = scheduleBehaviorProvider

        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            guard self.isOpen == false else {
                self.logger.error("already open")
                completion(false, nil)
                return
            }

            self.logger.log("Starting open operation")

            guard let scheduleBehavior = self.scheduleBehavior else {
                self.logger.error("schedule behavior is nil")
                return
            }

            self.isOpen = true

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            if !self.storage.exists {
                self.actuallyReset(scheduleBehavior: scheduleBehavior) { success, error in
                    defer { dispatchGroup.leave() }
                    completion(success, error)
                }
            } else {
                self.reopen(withScheduleBehavior: scheduleBehavior) { success, error in
                    defer { dispatchGroup.leave() }
                    completion(success, error)
                }
            }

            dispatchGroup.wait()
            self.logger.log("Exited open operation")
        }
    }

    public func update(scheduleItems: [ScheduleItem],
                       completion: ((_ success: Bool, _ items: [ScheduleItem]?, _ error: Error?) -> Void)? = nil) {
        guard !scheduleItems.isEmpty else {
            completion?(true, [], nil)
            return
        }

        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            self.actuallyUpdate(scheduleItems: scheduleItems) { success, items, error in
                defer { dispatchGroup.leave() }
                completion?(success, items, error)
            }

            dispatchGroup.wait()
            self.logger.log("Exited update operation")
        }
    }

    public func actuallyUpdate(scheduleItems: [ScheduleItem],
                               completion: @escaping (_ success: Bool, _ items: [ScheduleItem]?, _ error: Error?) -> Void) {
        guard let scheduleBehavior = self.scheduleBehavior else {
            self.logger.error("schedule behavior is nil")
            completion(false, nil, nil)
            return
        }
        self.logger.log("Starting update schedule items operation...")

        do {
            for item in scheduleItems where item.hasEventKitObjectChanges {
                try item.saveEventKitObject()
            }
        } catch {
            self.logger.error("saving items failed with error: \(String(describing: error))")
            completion(false, nil, error)
            return
        }

        var newIntermediateSchedule = self.schedule

        for (index, item) in newIntermediateSchedule.items.enumerated() {
            if let updatedItemIndex = scheduleItems.firstIndex(where: { $0.scheduleItemID == item.scheduleItemID }) {
                newIntermediateSchedule.items[index] = scheduleItems[updatedItemIndex]
            }
        }

        self.writeScheduleWithReload(true,
                                     newSchedule: newIntermediateSchedule,
                                     oldSchedule: self.schedule,
                                     scheduleBehavior: scheduleBehavior) { success, newSchedule, error in
            if success {
                guard let newSchedule = newSchedule else {
                    return
                }

                var outItems: [ScheduleItem] = []
                for item in newSchedule.items {
                    if let index = scheduleItems.firstIndex(where: { $0.scheduleItemID == item.scheduleItemID }) {
                        outItems.append(scheduleItems[index])
                    }
                }

                completion(true, outItems, nil)
            } else {
                completion(false, nil, error )
            }
        }
    }

    public func update(calendar: CalendarScheduleItem,
                       completion: ((_ success: Bool, _ calendar: CalendarScheduleItem?, _ error: Error?) -> Void)? = nil) {
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            guard let scheduleBehavior = self.scheduleBehavior else {
                self.logger.error("schedule behavior is nil")
                return
            }

            let oldSchedule = self.schedule

            do {
                if calendar.eventKitCalendar.hasChanges {
                    try calendar.eventKitCalendar.saveEventKitObject()
                }
            } catch {
                self.logger.error("failed to save calendar \(String(describing: error))")
                completion?(false, nil, error)
            }

            var newSchedule = oldSchedule
            if let newGroups = self.updateCalendarGroups(withNewCalendar: calendar, calendarGroups: newSchedule.calendars.calendarGroups) {
                newSchedule.calendars.calendarGroups = newGroups
            } else if let newGroups = self.updateCalendarGroups(withNewCalendar: calendar,
                                                                calendarGroups: newSchedule.calendars.delegateCalendarGroups) {
                newSchedule.calendars.delegateCalendarGroups = newGroups
            }

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            self.writeScheduleWithReload(true,
                                         newSchedule: newSchedule,
                                         oldSchedule: oldSchedule,
                                         scheduleBehavior: scheduleBehavior) { [weak self] success, _, error in
                defer { dispatchGroup.leave() }
                guard let self = self else { return }

                if success {
                    completion?(true, calendar, nil)

                    self.logger.log("updated calendar ok")
                } else {
                    self.logger.error("updating calendar failed with error: \(String(describing: error))")
                    completion?(false, nil, error)
                }
            }

            dispatchGroup.wait()
            self.logger.log("Exited update calendar operation")
        }
    }

    public func enableAllPersonalCalendars(completion: ((_ success: Bool, _ schedule: Schedule?, _ error: Error?) -> Void)? = nil) {
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()

            let oldSchedule = self.schedule
            var newSchedule = oldSchedule
            newSchedule.calendars.enableAllPersonalCalendars()

            self.writeSchedule(newSchedule: newSchedule,
                               oldSchedule: oldSchedule) { [weak self] success, _, error in
                defer { dispatchGroup.leave() }
                guard let self = self else { return }

                if success {
                    completion?(true, newSchedule, nil)

                    self.logger.log("updated calendar ok")
                } else {
                    self.logger.error("updating calendar failed with error: \(String(describing: error))")
                    completion?(false, nil, error)
                }
            }

            dispatchGroup.wait()
            self.logger.log("Exited update all personal calendars operation")
        }
    }

    fileprivate func updateCalendarGroups(withNewCalendar updatedCalendar: CalendarScheduleItem,
                                          calendarGroups: [CalendarGroup]) -> [CalendarGroup]? {
        var newGroupList: [CalendarGroup] = []

        for group in calendarGroups {
            var newCalendars: [CalendarScheduleItem] = []

            for groupCalendar in group.calendars {
                var newCalendar = groupCalendar

                if updatedCalendar.eventKitCalendar.id == newCalendar.eventKitCalendar.id {
                    newCalendar = updatedCalendar
                }

                newCalendars.append(newCalendar)
            }

            newGroupList.append(CalendarGroup(withCalendarSource: group.source,
                                              calendars: newCalendars))
        }

        return newGroupList == calendarGroups ? nil: newGroupList
    }
}

extension ScheduleController: EventKitDataModelControllerDelegate {
    public func eventKitDataModelControllerNeedsReload(_ eventKitDataModelController: EventKitDataModelController) {
        self.reload()
    }
}

extension ScheduleController {
    fileprivate func autoUpdateReminderPriorities(completion: ((_ success: Bool, _ items: [ScheduleItem]?, _ error: Error?) -> Void)? = nil) {
        self.operationQueue.addOperation { [weak self] in
            guard let self = self else { return }

            guard let scheduleBehavior = self.scheduleBehavior else {
                self.logger.error("schedule behavior is nil")
                return
            }

            let days = scheduleBehavior.reminderScheduleBehavior.automaticallyIncreasePriorityDays

            guard days > 0 else {
                return
            }

            let now = Date()

            var remindersToUpdate: [ReminderScheduleItem] = []

            for item in self.schedule.items {
                guard let reminder = item as? ReminderScheduleItem else {
                    continue
                }

                let priority = reminder.priority
                guard priority != .high else {
                    continue
                }

                if let lastDate = reminder.reminderStorageRecord.lastPriorityUpgradeDate {
                    if lastDate.addDays(days).isBeforeDate(now) {
                        remindersToUpdate.append(reminder)
                    }
                    // else do nothing
                } else if let creationDate = reminder.creationDate {
                    if creationDate.addDays(days).isBeforeDate(now) {
                        remindersToUpdate.append(reminder)
                    }
                }
            }

            if !remindersToUpdate.isEmpty {
                for i in 0..<remindersToUpdate.count {
                    remindersToUpdate[i].increasePriority()
                    self.logger.log("bumped priority for reminder: \(remindersToUpdate[i].description)")
                }

                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()

                self.actuallyUpdate(scheduleItems: remindersToUpdate) { success, items, error in
                    defer { dispatchGroup.leave() }
                    completion?(success, items, error)
                }

                dispatchGroup.wait()
            }

            self.logger.log("Exited enqueueAutoUpdateReminderPriorities")
        }
    }

    fileprivate func createSchedule(withStoredScheduleData storedScheduleData: ScheduleStorageRecord,
                                    eventKitDataModel: EventKitDataModel,
                                    scheduleBehavior: ScheduleBehavior) -> Schedule {
        let newSchedule = self.factory.createSchedule(withStoredScheduleData: storedScheduleData,
                                                      eventKitDataModel: eventKitDataModel,
                                                      scheduleBehavior: scheduleBehavior)

        return newSchedule
    }

    fileprivate func actuallyReload(scheduleBehavior: ScheduleBehavior,
                                    completion: @escaping (_ success: Bool, _ schedule: Schedule?, _ error: Error? ) -> Void) {
        let oldSchedule = self.schedule
        let storedData = ScheduleStorageRecord(withSchedule: oldSchedule)

        let rules = EventKitRules(withStoredScheduleData: storedData,
                                  visibleDayCount: scheduleBehavior.calendarScheduleBehavior.visibleDayCount)

        self.eventKitDataModelController.reload(withRules: rules) { [weak self] dataModel in
            guard let self = self else { return }

            self.logger.log("Reloaded eventKitDataModel ok, starting to update schedule...")

            let newSchedule = self.createSchedule(withStoredScheduleData: storedData,
                                                  eventKitDataModel: dataModel,
                                                  scheduleBehavior: scheduleBehavior)

            self.writeSchedule(newSchedule: newSchedule,
                               oldSchedule: oldSchedule) { [weak self] success, finishedSchedule, error in
                guard let self = self else { return }

                guard success else {
                    self.logger.error("reload operation failed with error: \(String(describing: error))")
                    completion(success, finishedSchedule, error)
                    return
                }

                self.logger.log("schedule updated ok, reload complete")
                completion(success, finishedSchedule, error)

                self.autoUpdateReminderPriorities()
            }
        }
    }

    fileprivate func actuallyReset(scheduleBehavior: ScheduleBehavior,
                                   completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        let oldSchedule = self.schedule

        let newStoredData = ScheduleStorageRecord()

        self.logger.log("Reloaded eventKitDataModel for reset...")

        let rules = EventKitRules(withStoredScheduleData: newStoredData,
                                  visibleDayCount: scheduleBehavior.calendarScheduleBehavior.visibleDayCount)

        let callback: (_ dataModel: EventKitDataModel) -> Void = { [weak self] dataModel in
            guard let self = self else { return }

            var initialSchedule = self.createSchedule(withStoredScheduleData: newStoredData,
                                                      eventKitDataModel: dataModel,
                                                      scheduleBehavior: scheduleBehavior)

            initialSchedule.calendars.enableAllPersonalCalendars()

            let initialStoredData = initialSchedule.createStorageRecord()

            let updatedRules = EventKitRules(withStoredScheduleData: initialStoredData,
                                             visibleDayCount: scheduleBehavior.calendarScheduleBehavior.visibleDayCount)

            self.eventKitDataModelController.reload(withRules: updatedRules) { [weak self] dataModel in
                guard let self = self else { return }

                self.logger.log("Reloaded eventKitDataModel for reset ok")

                let newSchedule = self.createSchedule(withStoredScheduleData: initialStoredData,
                                                      eventKitDataModel: dataModel,
                                                      scheduleBehavior: scheduleBehavior)

                self.writeSchedule(newSchedule: newSchedule,
                                   oldSchedule: oldSchedule) { [weak self] success, _, error in
                    guard let self = self else { return }
                    self.logger.log("Starting reset operation")

                    guard success else {
                        self.logger.error("reset operation failed with error: \(String(describing: error))")
                        completion(success, error)
                        return
                    }

                    self.logger.log("reset operation finished ok")
                    completion(success, error)
                }
            }
        }

        if self.eventKitDataModelController.isOpen {
            self.eventKitDataModelController.reload(withRules: rules, completion: callback)
        } else {
            self.eventKitDataModelController.open(withRules: rules, completion: callback)
        }
    }

    fileprivate func reopen(withScheduleBehavior scheduleBehavior: ScheduleBehavior,
                            completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        self.logger.log("Starting reopen...")
        self.storage.read { success, storedData, error in
            if success {
                self.logger.log("read data model ok on open")

                guard let storedData = storedData else {
                    completion(false, nil)
                    return
                }

                let rules = EventKitRules(withStoredScheduleData: storedData,
                                          visibleDayCount: scheduleBehavior.calendarScheduleBehavior.visibleDayCount)

                self.eventKitDataModelController.open(withRules: rules) { [weak self] dataModel in
                    guard let self = self else { return }

                    self.schedule = self.createSchedule(withStoredScheduleData: storedData,
                                                        eventKitDataModel: dataModel,
                                                        scheduleBehavior: scheduleBehavior)

                    self.storage.writeScheduleDataIfNeeded(storedData) { success, error in
                        completion(success, error)
                    }
                }
            } else {
                self.logger.error("reading data model failed with error: \(String(describing: error)), performing reset")
                self.reset(completion: completion)

                DispatchQueue.main.async {
                    self.showReadError()
                }
            }
        }
    }

    fileprivate func writeScheduleWithReload(_ reload: Bool,
                                             newSchedule: Schedule,
                                             oldSchedule: Schedule,
                                             scheduleBehavior: ScheduleBehavior,
                                             completion: @escaping(_ success: Bool, _ schedule: Schedule?, _ error: Error?) -> Void) {
        self.writeSchedule(newSchedule: newSchedule,
                           oldSchedule: oldSchedule) { [weak self] success, updatedSchedule, error in
            guard let self = self else { return }

            guard success else {
                self.logger.error("updating schedule failed with error \(String(describing: error))")
                completion(false, nil, error)
                return
            }

            self.schedule = newSchedule

            if reload {
                self.actuallyReload(scheduleBehavior: scheduleBehavior) { [weak self] success, newSchedule, error in
                    guard let self = self else { return }

                    guard success else {
                        self.logger.error("reload failed on update with error: \(String(describing: error))")
                        completion(false, nil, error)
                        return
                    }

                    guard let newSchedule = newSchedule else {
                        self.logger.error("new schedule was unexpectedly nil")
                        completion(false, nil, error)
                        return
                    }

                    self.schedule = newSchedule

                    self.logger.info("reload for saving items loaded: \(newSchedule.items.count) items")

                    completion(true, newSchedule, nil)
                }
            } else {
                guard let updatedSchedule = updatedSchedule else {
                    assertionFailure("schedule is unexpectedly nil")
                    return
                }

                self.logger.info("update schedule with reload finished without reload: \(updatedSchedule.items.count) items")

                completion(success, updatedSchedule, error)
            }
        }
    }
}

extension ScheduleController {
    fileprivate func showReadError() {
        let alert = NSAlert()
        alert.messageText = "Dang, Rooster had a problem reading stored Calendar information"
        alert.informativeText = "Your Calendar settings and saved event preferences were reset to the default settings."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        if alert.runModal() == .alertFirstButtonReturn {
        }
    }

    fileprivate func notify(newSchedule: Schedule, oldSchedule: Schedule) {
        self.notifier.schedule { [weak self] in
            guard let self = self else { return }

            self.logger.log("EventDataModel did change notification sent")

            let userInfo = [
                Self.oldScheduleKey: oldSchedule,
                Self.newScheduleKey: newSchedule
            ]

            NotificationCenter.default.post(name: Self.scheduleDidChangeEvent, object: self, userInfo: userInfo)
        }
    }

    internal func writeSchedule(newSchedule: Schedule,
                                oldSchedule: Schedule,
                                completion: @escaping(_ success: Bool, _ schedule: Schedule?, _ error: Error?) -> Void) {
        guard self.isOpen == true else {
            self.logger.log("not open yet, not saving")
            completion(false, nil, nil)
            return
        }

        self.logger.log("writing new schedule data")

        self.storage.writeScheduleDataIfNeeded(newSchedule) { [weak self] success, error in
            guard let self = self else { return }

            if success {
                self.schedule = newSchedule

                self.logger.log("did write schedule data")

                completion(true, newSchedule, nil)
            } else {
                self.logger.log("writing schedule data failed with error: \(String(describing: error))")
                // FUTURE: handle failure?? Prompt user??

                completion(false, nil, nil)
            }
        }
    }
}

extension Notification {
    var oldSchedule: Schedule? {
        self.userInfo?[ScheduleController.oldScheduleKey] as? Schedule
    }
    var newSchedule: Schedule? {
        self.userInfo?[ScheduleController.newScheduleKey] as? Schedule
    }
}

// swiftlint:enable cyclomatic_complexity
