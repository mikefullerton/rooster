//
//  ScheduleItem.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

// swiftlint:disable file_types_order

public protocol ScheduleItem: Enableable, CalendarItem {
    var eventKitItemID: String { get }

    var canExpire: Bool { get }

    var dateRange: DateRange? { get }

    var alarm: ScheduleItemAlarm? { get set }

    var typeDisplayName: String { get }

    var timeLabelDisplayString: String { get }

    var scheduleDay: Date? { get }

    func saveEventKitObject() throws

    var hasEventKitObjectChanges: Bool { get }
}

internal protocol StorableScheduleItem {
    var storageRecord: ScheduleItemStorageRecord { get }
}

// extension EventKitCalendarItem {
//    public func uniqueID(forStartDate startDate: Date) -> String {
//        let components = Foundation.Calendar.current.dateComponents([.year, .day, .month], from: startDate)
//
//        let id = """
//        \(self.calendar.id)+\
//        \(self.id)+\
//        \(components.month!)-\(components.day!)-\(components.year!)
//        """
//
//        return id
//    }
// }

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
