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

class ReminderListViewCell : CalendarItemListViewCell {
    
//    override var imageButtonIcon: SDKImage? {
//        let config = NSImage.SymbolConfiguration(scale: .medium)
//        return NSImage(systemSymbolName: "list.bullet", accessibilityDescription: "Reminder")?.withSymbolConfiguration(config)
//    }
 
    override var itemTypeString: String {
        return "Reminder"
    }

    public static var questionImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "questionmark.square",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .large))!
    }

    public static var checkMarkImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "checkmark",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }
    
    public static var noPriorityImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "questionmark",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var lowPriorityImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "exclamationmark",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var mediumPriorityImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "exclamationmark.2",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public static var highPriorityImage: NSImage {
        return  NSImage.image(withSystemSymbolName: "exclamationmark.3",
                              accessibilityDescription: "complete reminder",
                              symbolConfiguration: NSImage.SymbolConfiguration(scale: .medium))!
    }

    public lazy var priorityMenuButton: Button = {
        
        var menuItems = [
        
            NSMenuItem(title: "Low",
                       image: Self.lowPriorityImage,
                       target: self,
                       action: #selector(setPriority(_:)),
                       keyEquivalent: "",
                       tag: RCReminder.Priority.low.rawValue),
            
            NSMenuItem(title: "Medium",
                       image: Self.mediumPriorityImage,
                       target: self,
                       action: #selector(setPriority(_:)),
                       keyEquivalent: "",
                       tag: RCReminder.Priority.medium.rawValue),
            
            NSMenuItem(title: "High",
                       image: Self.highPriorityImage,
                       target: self,
                       action: #selector(setPriority(_:)),
                       keyEquivalent: "",
                       tag: RCReminder.Priority.high.rawValue),
            
            NSMenuItem.separator(),
            
            NSMenuItem(title: "No priority",
                       image: Self.noPriorityImage,
                       target: self,
                       action: #selector(setPriority(_:)),
                       keyEquivalent: "",
                       tag: RCReminder.Priority.none.rawValue)
        ]
        
        let menu = NSMenu()
        menu.items = menuItems
        
        return Button(image: Self.noPriorityImage, menu: menu)
    }()
    
    @objc func setPriority(_ sender: NSMenuItem) {
        
        guard   var reminder = self.reminder,
                let menuReminderID = sender.representedObject as? String,
                menuReminderID == reminder.id  else {
            return
        }
        
        reminder.priority = RCReminder.Priority(rawValue: sender.tag) ?? .none
            
        Controllers.reminders.save(reminder: reminder)
    }
    
    func priorityButton(forReminder reminder: RCReminder) -> SDKView {
    
        let button = self.priorityMenuButton
        
        switch reminder.priority {
        case .low:
            button.setExclusiveMenuState(.on, forMenuItemAtIndex: 0)
            button.image = Self.lowPriorityImage

        case .medium:
            button.setExclusiveMenuState(.on, forMenuItemAtIndex: 1)
            button.image = Self.mediumPriorityImage

        case .high:
            button.setExclusiveMenuState(.on, forMenuItemAtIndex: 2)
            button.image = Self.highPriorityImage

        case .none:
            button.setExclusiveMenuState(.on, forMenuItemAtIndex: 4)
            button.image = Self.noPriorityImage
        }
        
        button.representedObject = reminder.id
        
        button.preferredContentSize = Self.highPriorityImage.size
        
        
        return button
    }

    private var remindMeMenu: NSMenu {
        
        let menu = NSMenu()
        menu.items = [
            
            NSMenuItem(title: "Complete Reminder",
                       target: self,
                       action: #selector(completeReminder(_:))),
            
            NSMenuItem.separator(),
            
            NSMenuItem(title: "Remind Me Later",
                       target: self,
                       action: #selector(remindMeLater(_:))),
            
            NSMenuItem(title: "Remind Me Tomorrow",
                       target: self,
                       action: #selector(remindMeTomorrow(_:)))
        ]
        
        return menu
    }
    
    lazy var remindMeButton = Button(image: Self.questionImage, menu: self.remindMeMenu)
    
    lazy var remindMeButtonWithRemoveDueDate: Button = {
        
        var menu = self.remindMeMenu
        
        menu.addItem(NSMenuItem.separator())
            
        menu.addItem(NSMenuItem(title: "Remove Due Date",
                                        target: self,
                                        action: #selector(removeDueDates(_:))))
    
        return Button(image: Self.questionImage, menu: menu)
    }()
    
    func remindersButton(forReminder reminder: RCReminder) -> SDKView {
    
        let button = reminder.hasDates ? self.remindMeButtonWithRemoveDueDate : self.remindMeButton

        if reminder.isCompleted {
            button.image = Self.checkMarkImage.tint(color: NSColor.systemGreen)
        } else if reminder.dueDate != nil && reminder.dueDate!.isBeforeDate(Date()) {
            button.image = Self.checkMarkImage.tint(color: NSColor.systemRed)
        } else {
            
            if reminder.alarm.isHappeningNow {
                button.image = Self.checkMarkImage.tint(color: NSColor.systemYellow)
            } else {
                button.image = Self.checkMarkImage
            }
        }
        
        button.representedObject = reminder
        
        return button
    }
    
    var reminder: RCReminder? {
        return self.rowItem?.calendarItem as? RCReminder
    }
    
    @objc func completeReminder(_ sender: NSMenuItem) {
        if let reminder = self.reminder {
            Controllers.reminders.complete(reminder)
        }
    }
    
    @objc func remindMeLater(_ sender: NSMenuItem) {
        if let reminder = self.reminder {
            Controllers.reminders.remindLater(reminder)
        }
    }

    @objc func remindMeTomorrow(_ sender: NSMenuItem) {
        if let reminder = self.reminder {
            Controllers.reminders.remindTomorrow(reminder)
        }
    }
    
    @objc func removeDueDates(_ sender: NSMenuItem) {
        if let reminder = self.reminder {
            Controllers.reminders.removeDueDates(reminder)
        }
    }
    
    public override func updateActionButtons(_ actionButtons: inout [SDKView],
                                             forRowItem rowItem: EventListRowItem) {

        if let reminder = rowItem.calendarItem as? RCReminder {
            actionButtons.append(self.priorityButton(forReminder: reminder))
            actionButtons.append(self.remindersButton(forReminder: reminder))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentViews.startCountDownLabel.outputFormatter = { _, countdown in
            return " (Reminder is due in \(countdown))"
        }
        
        self.contentViews.endCountDownLabel.outputFormatter = { _, countdown in
            return " (Reminder will be past due in \(countdown))"
        }
    }

    override func updateForPastEvent(forRowItem rowItem: EventListRowItem) {
        super.updateForPastEvent(forRowItem: rowItem)
        
        if rowItem.calendarItem.hasDates {
            self.contentViews.startCountDownLabel.stringValue = " (Reminder is past due)"
            self.contentViews.startCountDownLabel.isHidden = false
        }
    }

}
