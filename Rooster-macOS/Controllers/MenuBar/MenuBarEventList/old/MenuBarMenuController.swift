//
//  MenuBarMenu.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import Foundation
import RoosterCore

public class MenuBarMenuController: NSObject, Loggable, NSMenuDelegate {
    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    let menu = NSMenu()

    var controllers: [ListViewRowController] = []

    public static let menuWidth: CGFloat = 500

    override public init() {
        super.init()
        self.menu.delegate = self

        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.updateMenu()
        }

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.updateMenu()
        }
    }

    func createMenuItem(forScheduleItem item: ScheduleItem) -> NSMenuItem? {
        guard !item.isAllDay && item.alarm != nil else {
            return nil
        }

        if item as? EventScheduleItem != nil {
            let row = EventListListViewCell()
            row.willDisplay(withContent: item)
            return MenuItem(withViewController: row)
        }

        if item as? ReminderScheduleItem != nil {
            let row = ReminderListViewCell()
            row.willDisplay(withContent: item)
            row.resizeToFitInMenu()
            return MenuItem(withViewController: row)
        }

        assertionFailure("Unknown type of schedule item")
        return nil
    }

    lazy var additionalMenuItems: [NSMenuItem] = {
        let menuBarChoices: [NSMenuItem] = [
            MenuItem(withView: SDKView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))),

            MenuItem(title: "Show Main Window", systemSymbolName: "eye") { _ in
                AppControllers.shared.bringAppForward()
            },

            NSMenuItem.separator(),

            MenuItem(title: "Preferences…", systemSymbolName: "gearshape") { _ in
                AppControllers.shared.showPreferencesWindow()
            },

            MenuItem(title: "Calendars…", systemSymbolName: "calendar") { _ in
                AppControllers.shared.showCalendarsWindow()
            },
            NSMenuItem.separator(),

            MenuItem(title: "File Radar…", systemSymbolName: "ladybug") { _ in
                AppControllers.shared.showRadarAlert()
            },
            NSMenuItem.separator(),

            MenuItem(title: "Quit", systemSymbolName: "xmark") { _ in
                AppControllers.shared.appDelegate.quitRooster()
            }
        ]

//        let menuBarChoices: [MenuItem] = [
//            MenuItem(withView: MenuBarMenuChoiceView(withTitle: "Show Rooster", systemSymbolName: "eye")) { _ in
//                AppControllers.shared.bringAppForward()
//            },
//
//            MenuItem(withView: MenuBarMenuChoiceView(withTitle: "Preferences…", systemSymbolName: "gearshape")) { _ in
//                AppControllers.shared.showPreferencesWindow()
//            },
//
//            MenuItem(withView: MenuBarMenuChoiceView(withTitle: "Calendars…", systemSymbolName: "gearshape")) { _ in
//                AppControllers.shared.showCalendarsWindow()
//            },
//
//            MenuItem(withView: MenuBarMenuChoiceView(withTitle: "File Radar…", systemSymbolName: "ladybug")) { _ in
//                AppControllers.shared.showRadarAlert()
//            },
//
//            MenuItem(withView: MenuBarMenuChoiceView(withTitle: "Quit", systemSymbolName: "xmark")) { _ in
//                AppControllers.shared.appDelegate.quitRooster()
//            }
//        ]

        return menuBarChoices
    }()

    public func updateMenu() {
        let schedule = CoreControllers.shared.scheduleController.schedule

        let menu = self.menu
        menu.removeAllItems()

        let itemsByDay = schedule.scheduleItemsByDay
        for day in itemsByDay {
            if !day.date.isToday {
                break
            }

            let dayBanner = DayBannerRow()
            dayBanner.willDisplay(withContent: day.date)

            menu.addItem(MenuItem(withViewController: dayBanner))

            day.items.forEach { item in
                if let row = self.createMenuItem(forScheduleItem: item) {
                    menu.addItem(row)
                }
            }
        }

        if menu.items.isEmpty {
            menu.addItem(MenuItem(withViewController: NoMeetingsListViewCell()))
        }

        self.additionalMenuItems.forEach { menu.addItem($0) }

        for item in menu.items {
            if let view = item.view {
                var frame = view.frame
                frame.size.width = Self.menuWidth
                view.frame = frame
            }
        }
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        self.updateMenu()
    }

    public func numberOfItems(in menu: NSMenu) -> Int {
        self.menu.items.count
    }

    public func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        false
    }

    public func menuHasKeyEquivalent(_ menu: NSMenu,
                                     for event: NSEvent,
                                     target: AutoreleasingUnsafeMutablePointer<AnyObject?>,
                                     action: UnsafeMutablePointer<Selector?>) -> Bool {
        false
    }

    public func menuWillOpen(_ menu: NSMenu) {
        self.updateMenu()
    }

    public func menuDidClose(_ menu: NSMenu) {
    }

    public func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
    }
}
