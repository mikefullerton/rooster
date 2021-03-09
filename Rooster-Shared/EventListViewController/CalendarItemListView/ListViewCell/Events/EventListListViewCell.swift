//
//  EventListListViewCell.swift
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

open class EventListListViewCell: CalendarItemListViewCell {
//    override var imageButtonIcon: SDKImage? {
//        let config = NSImage.SymbolConfiguration(scale: .medium)
//        return NSImage(systemSymbolName: "calendar", accessibilityDescription: "Reminder")?.withSymbolConfiguration(config)
//    }
//
    override var itemTypeString: String {
        "Event"
    }

    var eventScheduleItem: EventScheduleItem? {
        self.scheduleItem as? EventScheduleItem
    }

    static var imageConfig: NSImage.SymbolConfiguration {
        NSImage.SymbolConfiguration(scale: .large)
    }

    static var checkMarkImage: NSImage {
        NSImage.image(withSystemSymbolName: "checkmark.circle",
                      accessibilityDescription: "Event Status",
                      symbolConfiguration: Self.imageConfig)!
    }

    static var questionMarkImage: NSImage {
        NSImage.image(withSystemSymbolName: "questionmark.circle",
                      accessibilityDescription: "Event Status",
                      symbolConfiguration: Self.imageConfig)!
            .tint(color: NSColor.systemYellow)
    }

    static var declineImage: NSImage {
        NSImage.image(withSystemSymbolName: "x.circle",
                      accessibilityDescription: "Event Status",
                      symbolConfiguration: Self.imageConfig)!
            .tint(color: NSColor.systemRed)
    }

    private func createStatusMenuItems(forEvent eventItem: EventScheduleItem) -> [NSMenuItem] {
        [
            MenuItem(title: "Accept",
                     image: Self.checkMarkImage.tint(color: NSColor.systemGreen)) { _ in
                var eventItem = eventItem
                eventItem.participationStatus = .accepted
                CoreControllers.shared.scheduleController.update(scheduleItems: [eventItem])
            },

            MenuItem(title: "Maybe",
                     image: Self.questionMarkImage) { _ in
                var eventItem = eventItem
                eventItem.participationStatus = .tentative
                CoreControllers.shared.scheduleController.update(scheduleItems: [eventItem])
            },

            MenuItem(title: "Decline",
                     image: Self.declineImage) { _ in
                var eventItem = eventItem
                eventItem.participationStatus = .declined
                CoreControllers.shared.scheduleController.update(scheduleItems: [eventItem])
            }
        ]
    }

    lazy var statusButton = PopUpMenuButton(image: Self.checkMarkImage)

    func statusButton(forEvent eventItem: EventScheduleItem) -> SDKView? {
        let status = eventItem.participationStatus

        let button = self.statusButton
        button.menuItems = self.createStatusMenuItems(forEvent: eventItem)

        let isEnabled = eventItem.allowsParticipationStatusModifications

        button.clearAllMenusStates()

        if status.isAccepted {
            button.image = Self.checkMarkImage.tint(color: NSColor(calibratedRed: 0, green: 1, blue: 0, alpha: 0.5))
            button.menuItems[0].state = .on
        } else if status.isTentative {
            button.menuItems[1].state = .on
            button.image = Self.questionMarkImage
        } else if status.isDeclined {
            button.menuItems[2].state = .on
            button.image = Self.declineImage
        } else {
            button.image = Self.checkMarkImage
            button.isEnabled = false
        }

        button.menuItems.forEach { $0.isEnabled = isEnabled }

        return button
    }

    override public func updateActionButtons(_ actionButtons: inout [SDKView]) {
    }

    override public func updateLeadingActionButtons(_ actionButtons: inout [SDKView]) {
        if let eventItem = self.eventScheduleItem,
           eventItem.dateRange != nil,
           let button = self.statusButton(forEvent: eventItem) {
            actionButtons.append(button)
        }
    }

    override open func willDisplay(withContent content: Any?) {
        super.willDisplay(withContent: content)

        if  let eventItem = self.eventScheduleItem,
            let currentUser = eventItem.currentUser,
            currentUser.participantStatus.isTentative {
            self.contentViews.notAcceptedOverlay.isHidden = false
        }

        if  let eventItem = self.eventScheduleItem {
            if eventItem.isAllDay || eventItem.isMultiday {
                self.contentViews.addAllDayTextField(withDateRange: eventItem.eventDateRange)
            } else {
                self.contentViews.allDayTextField.removeFromSuperview()
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.contentViews.startCountDownLabel.outputFormatter = { _, countdown in
            " (Event starts in \(countdown))"
        }

        self.contentViews.endCountDownLabel.outputFormatter = { _, countdown in
            " (Event ends in \(countdown))"
        }
    }
}
