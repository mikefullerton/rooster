//
//  ReminderScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import AppKit
import Foundation

public struct ReminderScheduleItem: ScheduleItem, Equatable, Identifiable, Reminder {
    public typealias ID = String

    // MARK: AbstractCalendarItem
    public let id: ID

    public func isEqual(to scheduleItem: AbstractEquatable) -> Bool {
        guard let other = scheduleItem as? Self else { return false }
        return self == other
    }

    // MARK: CalendarItem
    public var calendar: Calendar

    public var title: String {
        get { self.eventKitReminder.title }
        set { self.eventKitReminder.title = newValue }
    }

    public var location: String? {
        get { self.eventKitReminder.location }
        set { self.eventKitReminder.location = newValue }
    }

    public var notes: String? {
        get { self.eventKitReminder.notes }
        set { self.eventKitReminder.notes = newValue }
    }

    public var url: URL? {
        get { self.eventKitReminder.url }
        set { self.eventKitReminder.url = newValue }
    }

    public var isRecurring: Bool {
        self.eventKitReminder.isRecurring
    }

    public var hasParticipants: Bool {
        self.eventKitReminder.hasParticipants
    }

    public var participants: [Participant] {
        self.eventKitReminder.participants
    }

    public var isAllDay: Bool {
        self.eventKitReminder.isAllDay
    }

    public var isMultiday: Bool {
        self.alarm?.dateRange.isMultiDay ?? false
    }

    public var creationDate: Date? {
        self.eventKitReminder.creationDate
    }

    public var lastModifiedDate: Date? {
        self.eventKitReminder.lastModifiedDate
    }

    public var scheduleStartDate: Date? {
        self.eventKitReminder.scheduleStartDate
    }

    public var currentUser: Participant? {
        self.eventKitReminder.currentUser
    }

    // MARK: Reminder

    public var timeZone: TimeZone? {
        self.eventKitReminder.timeZone
    }

    public var startDate: Date? {
        self.eventKitReminder.startDate
    }

    public var dueDate: Date? {
        get { self.eventKitReminder.scheduleStartDate }
        set {
            self.eventKitReminder.scheduleStartDate = newValue
            self.calendarItemDateRangeDidChange()
        }
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

    public var priority: ReminderPriority {
        get {
            self.eventKitReminder.priority
        }
        set {
            self.eventKitReminder.priority = newValue
            self.reminderStorageRecord.lastPriorityUpgradeDate = Date()
        }
    }

    // MARK: ScheduleItem

    public var dateRange: DateRange? {
        self.alarm?.dateRange
    }

    public var alarm: ScheduleItemAlarm? {
        didSet {
            self.reminderStorageRecord.finishedDate = self.alarm?.finishedDate
        }
    }

    public internal(set) var reminderStorageRecord: ReminderScheduleItemStorageRecord

    internal var scheduleItemStorageRecord: ScheduleItemStorageRecord {
        self.reminderStorageRecord
    }

    fileprivate var eventKitReminder: EventKitReminder

    public var eventKitCalendarItem: EventKitCalendarItem {
        self.eventKitReminder
    }

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
        get { self.reminderStorageRecord.isEnabled }
        set { self.reminderStorageRecord.isEnabled = newValue }
    }

    public var eventKitItemID: String {
        self.eventKitReminder.id
    }

    public var scheduleDay: Date? {
        self.dateRange?.startDate.startOfDay
    }

    public mutating func increasePriority() {
        if self.eventKitReminder.priority < .high {
            self.priority = self.priority.increased
            self.reminderStorageRecord.lastPriorityUpgradeDate = Date()
        }
    }

    public var description: String {
        """
        \(type(of: self)) \
        id: \(self.id), \
        reminder: \(self.eventKitReminder.description) \
        date range: \(self.dateRange?.description ?? "no date range"), \
        alarm: \(self.alarm?.description ?? "no alarm"), \
        priority: \(self.priority.description), \
        storage Record: \(self.reminderStorageRecord.description)
        """
    }

    public var typeDisplayName: String {
        "Reminder"
    }

    public var timeLabelDisplayString: String {
        "Reminder Due at: \(self.dateRange?.startDate.shortTimeString ?? ""))"
    }

    public static func == (lhs: ReminderScheduleItem, rhs: ReminderScheduleItem) -> Bool {
        lhs.eventKitReminder == rhs.eventKitReminder &&
        lhs.alarm == rhs.alarm &&
        lhs.dateRange == rhs.dateRange &&
        lhs.isEnabled == rhs.isEnabled &&
        lhs.lengthInMinutes == rhs.lengthInMinutes &&
        lhs.calendar.isEqual(to: rhs.calendar) &&
        lhs.id == rhs.id &&
        lhs.reminderStorageRecord == rhs.reminderStorageRecord
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

    fileprivate mutating func calendarItemDateRangeDidChange() {
        if let startDate = self.dueDate {
            let finishedDate = self.alarm?.finishedDate
            let dateRange = DateRange(startDate: startDate, lengthInMinutes: self.lengthInMinutes)
            self.alarm = ScheduleItemAlarm(dateRange: dateRange, finishedDate: finishedDate)
        } else {
            self.alarm = nil
        }
    }

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

extension ReminderScheduleItem {
    public init(withReminder reminder: EventKitReminder,
                calendar: ScheduleCalendar,
                storageRecord: ReminderScheduleItemStorageRecord,
                scheduleBehavior: ScheduleBehavior) {
        self.id = String.guid
        self.calendar = calendar
        self.eventKitReminder = reminder
        self.reminderStorageRecord = storageRecord

        var dateRange: DateRange?
        var alarm: ScheduleItemAlarm?

        if reminder.isAllDay {
            dateRange = scheduleBehavior.calendarScheduleBehavior.workdayDateRange
        } else if let startDate = reminder.scheduleStartDate {
            dateRange = DateRange(startDate: startDate, lengthInMinutes: storageRecord.lengthInMinutes)
        }

        if let dateRange = dateRange {
            alarm = ScheduleItemAlarm(dateRange: dateRange,
                                      finishedDate: storageRecord.finishedDate)
        }

        self.alarm = alarm
    }
}
