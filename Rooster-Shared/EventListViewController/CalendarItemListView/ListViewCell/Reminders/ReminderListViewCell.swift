//
//  ReminderListViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class ReminderListViewCell: CalendarItemListViewCell {
    override open var itemTypeString: String {
        "Reminder"
    }

    private func createPriorityMenuItems(withReminderScheduleItem reminder: ReminderScheduleItem) -> [NSMenuItem] {
        [
            MenuItem(title: "Low",
                     image: Assets.lowPriorityImage) { _ in
                var reminder = reminder
                reminder.priority = .low
                CoreControllers.shared.scheduleController.update(scheduleItems: [reminder])
            },

            MenuItem(title: "Medium",
                     image: Assets.mediumPriorityImage) { _ in
                var reminder = reminder
                reminder.priority = .medium
                CoreControllers.shared.scheduleController.update(scheduleItems: [reminder])
            },

            MenuItem(title: "High",
                     image: Assets.highPriorityImage) { _ in
                var reminder = reminder
                reminder.priority = .high
                CoreControllers.shared.scheduleController.update(scheduleItems: [reminder])
            },

            NSMenuItem.separator(),

            MenuItem(title: "No priority",
                     image: Assets.noPriorityImage) { _ in
                var reminder = reminder
                reminder.priority = .none
                CoreControllers.shared.scheduleController.update(scheduleItems: [reminder])
            }
        ]
    }

    public lazy var priorityMenuButton = PopUpMenuButton(image: Assets.noPriorityImage)

    func priorityButton(forReminder reminder: ReminderScheduleItem) -> SDKView {
        let button = self.priorityMenuButton
        button.menuItems = self.createPriorityMenuItems(withReminderScheduleItem: reminder)

        button.clearAllMenusStates()

        switch reminder.priority {
        case .low:
            button.menuItems[0].state = .on
            button.title = "!"

        case .medium:
            button.menuItems[1].state = .on
            button.title = "!!"

        case .high:
            button.menuItems[2].state = .on
            button.title = "!!!"

        // 3 is separator

        case .none:
            button.menuItems[4].state = .on
            button.title = "-"
        }

        button.preferredContentSize = Assets.highPriorityImage.size
        return button
    }

    public func createRemindMeButtonItems(forReminder reminder: ReminderScheduleItem,
                                          withButton button: PopUpMenuButton) -> [NSMenuItem] {
        [
            MenuItem(title: "Complete Reminder") { _ in
                var reminder = reminder
                button.image = Assets.completionImage
                DispatchQueue.main.async {
                    Thread.sleep(forTimeInterval: 0.5)
                    reminder.setCompleted()
                }
            },

            NSMenuItem.separator(),

            MenuItem(title: "Remind Me Later") { _ in
                var reminder = reminder
                reminder.remindLater()
            },

            MenuItem(title: "Remind Me Tomorrow") { _ in
                var reminder = reminder
                reminder.remindTomorrow()
            }
        ]
    }

    public func createRemindMeButtonItemsWithRemoveDueData(forReminder reminder: ReminderScheduleItem,
                                                           withButton button: PopUpMenuButton) -> [NSMenuItem] {
        var items = self.createRemindMeButtonItems(forReminder: reminder, withButton: button)
        items.append(NSMenuItem.separator())

        items.append(MenuItem(title: "Remove Due Date") { _ in
            var reminder = reminder
            reminder.removeDueDates()
        })
        return items
    }

    lazy var remindMeButton = PopUpMenuButton(image: Assets.incompleteImage)

    func remindersButton(forReminderItem reminder: ReminderScheduleItem) -> SDKView {
        let button = self.remindMeButton

        if reminder.dueDate != nil {
            button.menuItems = self.createRemindMeButtonItemsWithRemoveDueData(forReminder: reminder, withButton: button)
        } else {
            button.menuItems = self.createRemindMeButtonItems(forReminder: reminder, withButton: button)
        }

        if reminder.isCompleted {
            button.image = Assets.completionImage.tint(color: NSColor.systemGreen)
        } else if reminder.dueDate != nil && reminder.dueDate!.isBeforeDate(Date()) {
            button.image = Assets.incompleteImage.tint(color: NSColor.systemRed)
        } else {
            if  reminder.alarm?.dateRange.isHappeningNow ?? false {
                button.image = Assets.incompleteImage.tint(color: NSColor.systemYellow)
            } else {
                button.image = Assets.incompleteImage
            }
        }

        return button
    }

    var reminderScheduleItem: ReminderScheduleItem? {
        self.scheduleItem as? ReminderScheduleItem
    }

    override public func updateActionButtons(_ actionButtons: inout [SDKView]) {
    }

    override public func updateLeadingActionButtons(_ actionButtons: inout [SDKView]) {
        if let scheduleItem = self.reminderScheduleItem {
            actionButtons.append(self.remindersButton(forReminderItem: scheduleItem))
            actionButtons.append(self.priorityButton(forReminder: scheduleItem))
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.contentViews.startCountDownLabel.outputFormatter = { _, countdown in
            " (Reminder is due in \(countdown))"
        }

        self.contentViews.endCountDownLabel.outputFormatter = { _, countdown in
            " (Reminder will be past due in \(countdown))"
        }
    }

    override public func updateForPastEvent() {
        super.updateForPastEvent()

        if let reminder = self.reminderScheduleItem,
            !reminder.isCompleted,
            reminder.dateRange != nil {
            self.contentViews.startCountDownLabel.stringValue = " (Reminder is past due)"
            self.contentViews.startCountDownLabel.isHidden = false
            self.contentViews.pastDueOverlay.isHidden = false
        }
    }

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        var height = 70.0

        if let scheduleItem = content as? ScheduleItem, scheduleItem.dateRange == nil {
            height = 30
        }

        if AppControllers.shared.preferences.calendar.options.contains(.showCalendarName) {
            height += 10
        }

        return CGSize(width: -1, height: height)
    }
}
