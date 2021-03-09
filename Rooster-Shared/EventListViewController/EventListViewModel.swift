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

open class EventListViewModel: ListViewModel {
    public init(withSchedule schedule: Schedule?, factory: EventListViewModel.Factory) {
        guard let schedule = schedule else {
            super.init(withSections: [])
            return
        }
        let sections = factory.createSections(withSchedule: schedule)
        super.init(withSections: sections)
    }
}

extension EventListViewModel {
    open class Factory {
        let dateRange: DateRange?
        var preferencesProvider: ValueProvider<SchedulePreferences>

        public private(set) var prefs: SchedulePreferences {
            get { self.preferencesProvider.value }
            set { self.preferencesProvider.value = newValue }
        }

        public init(withPreferencesProviders preferenceProvider: ValueProvider<SchedulePreferences>,
                    dateRange: DateRange? = nil) {
            self.preferencesProvider = preferenceProvider
            self.dateRange = dateRange
        }

        public func createRow(forScheduleItem item: ScheduleItem) -> Row? {
            if item as? EventScheduleItem != nil {
                return Row(withContent: item, rowControllerClass: EventListListViewCell.self)
            }

            if item as? ReminderScheduleItem != nil {
                return Row(withContent: item, rowControllerClass: ReminderListViewCell.self)
            }

            assertionFailure("Unknown type of schedule item")
            return nil
        }

        public let customSorter: (_ lhs: ScheduleItem, _ rhs: ScheduleItem) -> Bool = { lhs, rhs in
            if let lhs = lhs as? ReminderScheduleItem, let rhs = rhs as? ReminderScheduleItem {
                if lhs.priority == rhs.priority {
                    return lhs.title < rhs.title
                }

                return lhs.priority > rhs.priority
            }

            return lhs.title < rhs.title
        }

        public func createScheduledRows(forSchedule schedule: Schedule) -> [Section] {
            var sections: [Section] = []
            let itemsByDay = schedule.scheduleItemsByDay
            for day in itemsByDay {
                guard day.items.isEmpty == false || day.date.isToday else {
                    continue
                }

                if let dateRange = self.dateRange,
                   !dateRange.contains(day.date) {
                    break
                }

                var rows: [Row] = []

                if !day.date.isToday {
                    rows.append(Row(withContent: day.date, rowControllerClass: DayBannerRow.self))
                }

                var hasScheduledItems = false
                day.items.forEach { item in
                    if let row = self.createRow(forScheduleItem: item) {
                        rows.append(row)

                        if item.alarm != nil {
                            hasScheduledItems = true
                        }
                    }
                }

                if !hasScheduledItems {
                    rows.append(Row(withContent: NoMeetingsModelObject(date: day.date), rowControllerClass: NoMeetingsListViewCell.self))
                }

                sections.append(Section(withRows: rows))
            }
            return sections
        }

        public func createUnscheduledRows(forSchedule schedule: Schedule) -> Section? {
            var rows: [Row] = []
            var itemsWithoutDays = schedule.scheduleItemsWithoutDays
            if !itemsWithoutDays.isEmpty {
                itemsWithoutDays.sort(by: self.customSorter)

                rows.append(Row(withContent: self.preferencesProvider,
                                rowControllerClass: UnscheduledRemindersBanner.self))

                let priority = self.prefs.remindersPriorityFilter

                if self.prefs.remindersDisclosed {
                    for item in itemsWithoutDays {
                        if let reminder = item as? ReminderScheduleItem,
                           reminder.priority >= priority,
                           let row = self.createRow(forScheduleItem: item) {
                            rows.append(row)
                        }
                    }
                }
            }
            return rows.isEmpty ? nil : Section(withRows: rows)
        }

        public func createSections(withSchedule schedule: Schedule) -> [Section] {
            var sections: [Section] = self.createScheduledRows(forSchedule: schedule)

            if let unscheduled = self.createUnscheduledRows(forSchedule: schedule) {
                sections.append(unscheduled)
            }

            return sections
        }
    }
}
