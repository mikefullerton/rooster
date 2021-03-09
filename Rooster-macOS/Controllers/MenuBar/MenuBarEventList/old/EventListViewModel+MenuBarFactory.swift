//
//  EventListViewModel+MenuBarFactory.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/5/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension EventListViewModel {
    open class MenuBarFactory: Factory {
        private static let menuBarChoices: [MenuBarMenuChoice] = [
            MenuBarMenuChoice(title: "Show Rooster", systemSymbolName: "eye") {
                AppControllers.shared.bringAppForward()
            },

            MenuBarMenuChoice(title: "Preferences…", systemSymbolName: "gearshape") {
                AppControllers.shared.showPreferencesWindow()
            },

            MenuBarMenuChoice(title: "Calendars…", systemSymbolName: "gearshape") {
                AppControllers.shared.showCalendarsWindow()
            },

            MenuBarMenuChoice(title: "File Radar…", systemSymbolName: "ladybug") {
                AppControllers.shared.showRadarAlert()
            },

            MenuBarMenuChoice(title: "Quit", systemSymbolName: "xmark") {
                AppControllers.shared.appDelegate.quitRooster()
            }
        ]

        override open func didCreateRows(withSchedule schedule: Schedule) -> [Row] {
            Self.menuBarChoices.map { Row(withContent: $0, rowControllerClass: MenuBarMenuChoiceView.self) }
        }

        override open func createNoMeetingsRow() -> Row {
            Row(withContent: NoMeetingsModelObject(), rowControllerClass: MenuBarNoMeetingsListViewCell.self)
        }

        override open func createDayBannerRow(withStartDate startDate: Date) -> Row {
            Row(withContent: startDate, rowControllerClass: DayBannerRow.self)
        }

        override open func createEventRow(withScheduleItem item: ScheduleItem) -> Row {
            Row(withContent: item, rowControllerClass: MenuBarEventListListViewCell.self)
        }

        override open func createReminderRow(withScheduleItem item: ScheduleItem) -> Row {
            Row(withContent: item, rowControllerClass: MenuBarReminderListViewCell.self)
        }
    }
}
