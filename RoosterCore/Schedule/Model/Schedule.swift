//
//  Schedule.swift
//  Rooster-iOS
//
//  Created by Mike Fullerton on 3/27/21.
//

import Foundation

public struct Schedule: Equatable, Loggable {
    public var calendars: Calendars
    public var items: [ScheduleItem]

    public static func == (lhs: Schedule, rhs: Schedule) -> Bool {
        lhs.items.isEqual(to: rhs.items) &&
        lhs.calendars == rhs.calendars
    }

    public init() {
        self.calendars = Calendars()
        self.items = []
    }

    public init(calendars: Calendars,
                items: [ScheduleItem]) {
        self.calendars = calendars
        self.items = items
    }

    public func scheduleItem(forID id: String) -> ScheduleItem? {
        if let index = self.items.firstIndex(where: { $0.id == id }) {
            return self.items[index]
        }

        return nil
    }
}

extension Schedule {
    public struct Day {
        public let date: Date
        public let items: [ScheduleItem]
    }

    public var scheduleItemsByDay: [Day] {
        var days: [Date: [ScheduleItem]] = [Date().startOfDay: []]

        for item in items {
            guard let startDay = item.scheduleDay else {
                continue
            }

            if var list = days[startDay] {
                list.append(item)
                days[startDay] = list
            } else {
                let list: [ScheduleItem] = [
                    item
                ]
                days[startDay] = list
            }
        }

        var outDays: [Day] = []
        for (date, items) in days {
            outDays.append(Day(date: date, items: items))
        }

        return outDays.sorted { lhs, rhs in
            lhs.date < rhs.date
        }
    }

    public var scheduleItemsWithoutDays: [ScheduleItem] {
        var items: [ScheduleItem] = []
        for item in self.items {
            guard item.scheduleDay == nil else {
                continue
            }

            items.append(item)
        }
        return items
    }

    public var scheduleItemsByCalendarSource: [String: [ScheduleItem]] {
        Self.scheduleItemsByCalendarSource(self.items)
    }

    public static func scheduleItemsByCalendarSource(_ items: [ScheduleItem]) -> [String: [ScheduleItem]] {
        var result: [String: [ScheduleItem]] = [:]

        for item in items {
            let calendarSource = item.calendar.source

            if result[calendarSource.id] == nil {
                result[calendarSource.id] = [ item ]
            } else {
                result[calendarSource.id]!.append(item)
            }
        }

        return result
    }

    public var scheduleItemsByCalendar: [CalendarReference: [ScheduleItem]] {
        Self.scheduleItemsByCalendar(self.items)
    }

    public static func scheduleItemsByCalendar(_ items: [ScheduleItem]) -> [CalendarReference: [ScheduleItem]] {
        var result: [CalendarReference: [ScheduleItem]] = [:]

        for item in items {
            let calendarRef = CalendarReference(item.calendar)

            if result[calendarRef] == nil {
                result[calendarRef] = [ item ]
            } else {
                result[calendarRef]!.append(item)
            }
        }

        return result
    }
 }

extension Schedule {
//    public static func scheduleItemsAreEqual(_ lhs: [ScheduleItem], _ rhs: [ScheduleItem]) -> Bool {
//        guard lhs.count == rhs.count else {
//            return false
//        }
//
//        for i in 0..<lhs.count {
//            if !lhs[i].isEqual(to: rhs[i]) {
//                return false
//            }
//        }
//
//        return true
//    }
}

extension Schedule {
    public static var itemSorter: (_ lhs: ScheduleItem, _ rhs: ScheduleItem) -> Bool = { lhs, rhs in
        guard let lhsStart = lhs.dateRange?.startDate else {
            return true
        }

        guard let rhsStart = rhs.dateRange?.startDate else {
            return false
        }

        return lhsStart.isBeforeDate(rhsStart)
    }
}
