//
//  ReminderScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import AppKit
import Foundation

public struct ReminderScheduleItem: ScheduleItem, Equatable {
    public let scheduleItemID: String

    public var alarm: ScheduleItemAlarm? {
        didSet {
            self.reminderStorageRecord.finishedDate = self.alarm?.finishedDate
        }
    }

    public var dateRange: DateRange? {
        self.alarm?.dateRange
    }

    // swiftlint:disable force_cast
    fileprivate var eventKitReminder: EventKitReminder {
        get { self.eventKitCalendarItem as! EventKitReminder }
        set { self.eventKitCalendarItem = newValue }
    }

    public internal(set) var reminderStorageRecord: ReminderScheduleItemStorageRecord {
        get { self.scheduleItemStorageRecord as! ReminderScheduleItemStorageRecord }
        set { self.scheduleItemStorageRecord = newValue }
    }
    // swiftlint:enable force_cast

    public var eventKitCalendarItem: EventKitCalendarItem

    public var calendar: CalendarScheduleItem

    public let canExpire = false

    public var lengthInMinutes: Int {
        get {
            self.reminderStorageRecord.lengthInMinutes
        }
        set {
            self.reminderStorageRecord.lengthInMinutes = newValue
            self.calendarItemDateRangeDidChange()
        }
    }

    public var isEnabled: Bool {
        get { self.scheduleItemStorageRecord.isEnabled }
        set { self.scheduleItemStorageRecord.isEnabled = newValue }
    }

    public var isAllDay: Bool {
        self.eventKitReminder.isAllDay
    }

    public var isCompleted: Bool {
        get {
            self.eventKitReminder.isCompleted
        }
        set {
            self.eventKitReminder.isCompleted = newValue

            if newValue {
                self.alarm?.isFinished = true
            }
        }
    }

    public var completionDate: Date? {
        get { self.eventKitReminder.completionDate }
        set { self.eventKitReminder.completionDate = newValue }
    }

    public var notes: String? {
        get { self.eventKitReminder.notes }
        set { self.eventKitReminder.notes = newValue }
    }

    public var url: URL? {
        get { self.eventKitReminder.url }
        set { self.eventKitReminder.url = newValue }
    }

    public var location: String? {
        get { self.eventKitReminder.location }
        set { self.eventKitReminder.location = newValue }
    }

    public var isRecurring: Bool {
        self.eventKitReminder.isRecurring
    }

    public var eventKitItemID: String {
        self.eventKitReminder.id
    }

    public var priority: EventKitReminder.Priority {
        get {
            self.eventKitReminder.priority
        }
        set {
            self.eventKitReminder.priority = newValue
            self.reminderStorageRecord.lastPriorityUpgradeDate = Date()
        }
    }

    //    public var startDate: Date? {
    //        get { self.eventKitReminder.startDate }
    //        set { self.eventKitReminder.startDate = newValue }
    //    }

    public var dueDate: Date? {
        get { self.eventKitReminder.scheduleStartDate }
        set {
            self.eventKitReminder.scheduleStartDate = newValue
            self.calendarItemDateRangeDidChange()
        }
    }

    public var title: String {
        get { self.eventKitReminder.title }
        set { self.eventKitReminder.title = newValue }
    }

    public var scheduleDay: Date? {
        self.dateRange?.startDate.startOfDay
    }

    public var creationDate: Date? {
        self.eventKitReminder.creationDate
    }

    public var lastModificationDate: Date? {
        self.eventKitReminder.lastModifiedDate
    }

    public internal(set) var scheduleItemStorageRecord: ScheduleItemStorageRecord

    public mutating func increasePriority() {
        if self.eventKitReminder.priority < .high {
            self.priority = self.priority.increased
            self.reminderStorageRecord.lastPriorityUpgradeDate = Date()
        }
    }

    public var description: String {
        """
        \(type(of: self)) \
        scheduleItemID: \(self.scheduleItemID), \
        reminder: \(self.eventKitReminder.description) \
        date range: \(self.dateRange?.description ?? "no date range"), \
        alarm: \(self.alarm?.description ?? "no alarm"), \
        priority: \(self.priority.description), \
        storage Record: \(self.scheduleItemStorageRecord.description)
        """
    }

    public var typeDisplayName: String {
        "Reminder"
    }

    public var timeLabelDisplayString: String {
        "Reminder Due at: \(self.dateRange?.startDate.shortTimeString ?? ""))"
    }

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let other = scheduleItem as? Self else { return false }
        return self == other
    }

    public static func == (lhs: ReminderScheduleItem, rhs: ReminderScheduleItem) -> Bool {
        lhs.eventKitReminder == rhs.eventKitReminder &&
        lhs.alarm == rhs.alarm &&
        lhs.dateRange == rhs.dateRange &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.lengthInMinutes == rhs.lengthInMinutes &&
        lhs.alarm == rhs.alarm &&
        lhs.calendar == rhs.calendar &&
        lhs.scheduleItemID == rhs.scheduleItemID &&
        lhs.reminderStorageRecord == rhs.reminderStorageRecord
    }

    private mutating func calendarItemDateRangeDidChange() {
        if let startDate = self.dueDate {
            let finishedDate = self.alarm?.finishedDate
            let dateRange = DateRange(startDate: startDate, lengthInMinutes: self.lengthInMinutes)
            self.alarm = ScheduleItemAlarm(dateRange: dateRange, finishedDate: finishedDate)
        } else {
            self.alarm = nil
        }
    }

    public func saveEventKitObject() throws {
        try self.eventKitReminder.saveEventKitObject()
    }

    public var hasEventKitObjectChanges: Bool {
        self.eventKitReminder.hasChanges
    }
}

extension ReminderScheduleItem {
    public typealias CompletionBlock = (_ success: Bool, _ reminder: ReminderScheduleItem?, _ error: Error?) -> Void

    public mutating func updateDueDate(_ date: Date, completion: CompletionBlock?) {
        self.eventKitReminder.scheduleStartDate = date
        self.eventKitReminder.isCompleted = false
        self.eventKitReminder.completionDate = nil
        self.alarm = ScheduleItemAlarm(dateRange: DateRange(startDate: date,
                                                            lengthInMinutes: self.lengthInMinutes),
                                       finishedDate: self.reminderStorageRecord.finishedDate)
        self.alarm?.isFinished = false

        CoreControllers.shared.scheduleController.update(scheduleItems: [self]) { success, items, error in
            Self.handleCompletion(success: success, items: items, error: error, completion: completion)
        }
    }

    private static func handleCompletion(success: Bool, items: [ScheduleItem]?, error: Error?, completion: CompletionBlock?) {
        guard success else {
            self.logger.error("failed to save reminders with error: \(String(describing: error))")
            completion?(false, nil, error)
            return
        }

        guard let items = items else {
            self.logger.error("got nil items back, expecting one 1 item in list")
            completion?(false, nil, error)
            return
        }

        guard items.count == 1 else {
            self.logger.error("got \(items.count) items back, expecting one 1 item in list")
            completion?(false, nil, nil)
            return
        }

        guard let outItem = items[0] as? ReminderScheduleItem else {
            self.logger.error("didn't get a reminder back after save!")
            completion?(false, nil, nil)
            return
        }

        completion?(true, outItem, nil)
    }

    public mutating func remindLater(completion: CompletionBlock? = nil) {
        guard var desiredRange = CoreControllers.shared.scheduleController.scheduleBehavior?.calendarScheduleBehavior.workdayDateRange else {
            completion?(false, nil, nil)
            return
        }

        if let startDate = self.eventKitReminder.scheduleStartDate {
            desiredRange.startDate = Date.later(Date().removeMinutesAndSeconds.addHours(2),
                                                startDate.removeMinutesAndSeconds.addHours(2))
        } else {
            desiredRange.startDate = Date().removeMinutesAndSeconds.addHours(2)
        }

        var mutableReminder = self

        CoreControllers.shared.scheduleController.findEmptyTimeSlot(forScheduleItem: self,
                                                                    withinRange: desiredRange) { success, timeSlot in
            if success {
                assert(timeSlot != nil, "time slot is nil")
                if let timeSlot = timeSlot {
                    mutableReminder.updateDueDate(timeSlot.startDate, completion: completion)
                }
                completion?(success, mutableReminder, nil)
            } else {
                let alert = NSAlert()
                alert.messageText = """
                    No available time slots were found between \
                    \(desiredRange.startDate.shortTimeString) and
                    \(desiredRange.endDate.shortTimeString)"
                    """
                alert.alertStyle = .informational
                alert.addButton(withTitle: "OK")
                if alert.runModal() == .alertFirstButtonReturn {
                }

                completion?(false, nil, nil)
            }
        }
    }

    public mutating func remindTomorrow(completion: CompletionBlock? = nil) {
        let date = Date().removeMinutesAndSeconds.addDays(1)
        self.updateDueDate(date, completion: completion)
    }

    public mutating func setCompleted(completion: CompletionBlock? = nil) {
        self.eventKitReminder.isCompleted = true
        CoreControllers.shared.scheduleController.update(scheduleItems: [self]) { success, items, error in
            Self.handleCompletion(success: success, items: items, error: error, completion: completion)
        }
    }

    public mutating func removeDueDates(completion: CompletionBlock? = nil) {
        self.eventKitReminder.scheduleStartDate = nil
        self.alarm = nil
        self.eventKitReminder.isCompleted = false
        CoreControllers.shared.scheduleController.update(scheduleItems: [self]) { success, items, error in
            Self.handleCompletion(success: success, items: items, error: error, completion: completion)
        }
    }
}
