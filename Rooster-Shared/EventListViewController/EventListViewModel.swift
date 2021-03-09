//
//  EventListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public struct NoMeetingsModelObject {
}

open class EventListViewModel: ListViewModel {
    open class Factory {
        open func willCreateRows(withSchedule schedule: Schedule) -> [Row] {
            []
        }

        open func didCreateRows(withSchedule schedule: Schedule) -> [Row] {
            []
        }

        open func createNoMeetingsRow() -> Row {
            Row(withContent: NoMeetingsModelObject(), rowControllerClass: NoMeetingsListViewCell.self)
        }

        open func createDayBannerRow(withStartDate startDate: Date) -> Row {
            Row(withContent: startDate, rowControllerClass: DayBannerRow.self)
        }

        open func createEventRow(withScheduleItem item: ScheduleItem) -> Row {
            Row(withContent: item, rowControllerClass: EventListListViewCell.self)
        }

        open func createReminderRow(withScheduleItem item: ScheduleItem) -> Row {
            Row(withContent: item, rowControllerClass: ReminderListViewCell.self)
        }

        open func createUnscheduledBannerRow() -> Row {
            Row(withContent: BannerRow.Banner(banner: "Unscheduled Reminders", headline: nil), rowControllerClass: BannerRow.self)
        }

        private func createRow(forScheduleItem item: ScheduleItem) -> Row? {
            if item as? EventScheduleItem != nil {
                return self.createEventRow(withScheduleItem: item)
            }

            if item as? ReminderScheduleItem != nil {
                return self.createReminderRow(withScheduleItem: item)
            }

            assertionFailure("Unknown type of schedule item")
            return nil
        }

        private let customSorter: (_ lhs: ScheduleItem, _ rhs: ScheduleItem) -> Bool = { lhs, rhs in
            if let lhs = lhs as? ReminderScheduleItem, let rhs = rhs as? ReminderScheduleItem {
                if lhs.priority == rhs.priority {
                    return lhs.title < rhs.title
                }

                return lhs.priority > rhs.priority
            }

            return lhs.title < rhs.title
        }

        open func createSections(withSchedule schedule: Schedule) -> [Section] {
            var rows: [Row] = self.willCreateRows(withSchedule: schedule)

            let days = schedule.scheduleItemsByDay
            if days.isEmpty || !days.contains(where: { $0.date.isToday }) {
            }

            let itemsByDay = schedule.scheduleItemsByDay
            for day in itemsByDay {
                guard day.items.isEmpty == false || day.date.isToday else {
                    continue
                }

                rows.append(self.createDayBannerRow(withStartDate: day.date))

                if day.items.isEmpty {
                    rows.append(self.createNoMeetingsRow())
                } else {
                    day.items.forEach { item in
                        if let row = self.createRow(forScheduleItem: item) {
                            rows.append(row)
                        }
                    }
                }
            }

            var itemsWithoutDays = schedule.scheduleItemsWithoutDays
            if !itemsWithoutDays.isEmpty {
                itemsWithoutDays.sort(by: self.customSorter)

                rows.append(self.createUnscheduledBannerRow())
                for item in itemsWithoutDays {
                    if let row = self.createRow(forScheduleItem: item) {
                        rows.append(row)
                    }
                }
            }

            rows.append(contentsOf: self.didCreateRows(withSchedule: schedule))

            return [ Section(withRows: rows) ]
        }

        public init() {
        }
    }

    public init(withSchedule schedule: Schedule?,
                factory: Factory = Factory()) {
        guard let schedule = schedule else {
            super.init(withSections: [])
            return
        }

        super.init(withSections: factory.createSections(withSchedule: schedule))
    }
}
