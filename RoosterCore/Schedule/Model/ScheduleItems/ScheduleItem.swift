//
//  ScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

public protocol ScheduleItem: AbstractEquatable, Enableable, Loggable, CustomStringConvertible {
    var scheduleItemID: String { get }

    var eventKitItemID: String { get }

    var canExpire: Bool { get }

    var dateRange: DateRange? { get }

    var calendar: CalendarScheduleItem { get set }

    var alarm: ScheduleItemAlarm? { get set }

    var typeDisplayName: String { get }

    var timeLabelDisplayString: String { get }

    var isAllDay: Bool { get }

    var scheduleDay: Date? { get }

    var scheduleItemStorageRecord: ScheduleItemStorageRecord { get }

    func saveEventKitObject() throws

    var hasEventKitObjectChanges: Bool { get }

    var title: String { get set }

    var notes: String? { get set }

    var url: URL? { get set }

    var location: String? { get set }

    var isRecurring: Bool { get }

    var creationDate: Date? { get }

    var lastModificationDate: Date? { get }
}

extension EventKitCalendarItem {
    public func uniqueID(forStartDate startDate: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .day, .month], from: startDate)

        let id = """
        \(self.calendar.id)+\
        \(self.id)+\
        \(components.month!)-\(components.day!)-\(components.year!)
        """

        return id
    }
}

extension ScheduleItem {
    public var hasExpired: Bool {
        self.canExpire && (self.dateRange?.isInThePast ?? false)
    }

    public mutating func stopAlarmButtonClicked() {
        if self.alarm != nil {
            self.alarm!.isFinished = !self.alarm!.isFinished
            CoreControllers.shared.scheduleController.update(scheduleItems: [self])
        }
    }
}
