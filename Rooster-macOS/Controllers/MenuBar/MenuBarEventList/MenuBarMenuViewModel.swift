//
//  MenuBarMenuViewModel.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import Foundation
import RoosterCore

open class MenuBarMenuViewModel: ListViewModel {
    static func createRow(forScheduleItem item: ScheduleItem) -> Row? {
        guard !item.isAllDay && item.alarm != nil else {
            return nil
        }

        if item as? EventScheduleItem != nil {
            return Row(withContent: item, rowControllerClass: EventListListViewCell.self)
        }

        if item as? ReminderScheduleItem != nil {
            return Row(withContent: item, rowControllerClass: ReminderListViewCell.self)
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

//    static var additionMenuRows: [Row] {
//        let menuBarChoices: [MenuBarMenuChoiceView] = [
//            MenuBarMenuChoiceView(title: "Show Rooster", systemSymbolName: "eye") {
//                AppControllers.shared.bringAppForward()
//            },
//
//            MenuBarMenuChoiceView(title: "Preferences…", systemSymbolName: "gearshape") {
//                AppControllers.shared.showPreferencesWindow()
//            },
//
//            MenuBarMenuChoiceView(title: "Calendars…", systemSymbolName: "gearshape") {
//                AppControllers.shared.showCalendarsWindow()
//            },
//
//            MenuBarMenuChoiceView(title: "File Radar…", systemSymbolName: "ladybug") {
//                AppControllers.shared.showRadarAlert()
//            },
//
//            MenuBarMenuChoiceView(title: "Quit", systemSymbolName: "xmark") {
//                AppControllers.shared.appDelegate.quitRooster()
//            }
//        ]
//
//        return menuBarChoices.map { Row(withContent: $0, rowControllerClass: MenuBarMenuChoiceView.self) }
//    }

    public init(withSchedule schedule: Schedule) {
        var rows: [Row] = []

        var foundItem = false

        let itemsByDay = schedule.scheduleItemsByDay
        for day in itemsByDay {
            if !day.date.isToday {
                break
            }

            rows.append(Row(withContent: day.date, rowControllerClass: DayBannerRow.self))

            day.items.forEach { item in
                if let row = Self.createRow(forScheduleItem: item) {
                    foundItem = true
                    rows.append(row)
                }
            }
        }

        if !foundItem {
            rows.append(Row(withContent: NoMeetingsModelObject(), rowControllerClass: NoMeetingsListViewCell.self))
        }

//        rows.append(contentsOf: Self.additionMenuRows)

        super.init(withSections: [ Section(withRows: rows) ])
    }
}
