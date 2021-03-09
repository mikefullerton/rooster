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

class EventListListViewCell : CalendarItemListViewCell {
    
//    override var imageButtonIcon: SDKImage? {
//        let config = NSImage.SymbolConfiguration(scale: .medium)
//        return NSImage(systemSymbolName: "calendar", accessibilityDescription: "Reminder")?.withSymbolConfiguration(config)
//    }
//
    override var itemTypeString: String {
        return "Event"
    }
    
    var event: RCEvent? {
        return self.rowItem?.calendarItem as? RCEvent
    }
    
    @objc func maybe(_ sender: NSMenuItem) {
        if var event = self.event {
            event.participationStatus = .tentative

            Controllers.events.save(event: event)
        }
    }

    @objc func accept(_ sender: NSMenuItem) {
        if var event = self.event {
            event.participationStatus = .accepted

            Controllers.events.save(event: event)
        }
    }

    @objc func decline(_ sender: NSMenuItem) {
        if var event = self.event {
            event.participationStatus = .declined

            Controllers.events.save(event: event)
        }
    }
    
    static var imageConfig: NSImage.SymbolConfiguration {
        return NSImage.SymbolConfiguration(scale: .large)
    }

    static var checkMarkImage: NSImage {
        return NSImage.image(withSystemSymbolName: "checkmark.circle", accessibilityDescription: "Event Status", symbolConfiguration: Self.imageConfig)!
    }
    
    static var questionMarkImage: NSImage {
        return NSImage.image(withSystemSymbolName: "questionmark.circle", accessibilityDescription: "Event Status", symbolConfiguration: Self.imageConfig)!.tint(color: NSColor.systemYellow)
    }
    
    static var declineImage: NSImage {
        return NSImage.image(withSystemSymbolName: "x.circle", accessibilityDescription: "Event Status", symbolConfiguration: Self.imageConfig)!.tint(color: NSColor.systemRed)
    }
    
    lazy var statusMenu: NSMenu = {
        let menu = NSMenu()
        menu.items = [
            NSMenuItem(title: "Accept",
                       image: Self.checkMarkImage.tint(color: NSColor.systemGreen),
                       target: self,
                       action: #selector(accept(_:))),
            
            NSMenuItem(title: "Maybe",
                       image: Self.questionMarkImage,
                       target: self,
                       action: #selector(maybe(_:))),
            
            NSMenuItem(title: "Decline",
                       image: Self.declineImage,
                       target: self,
                       action: #selector(decline(_:)))

        ]
        
        return menu
    }()
    
    lazy var statusButton: Button = {
        let button = Button(image: Self.checkMarkImage, menu: self.statusMenu)
//        button.alphaValue = 0.75
        
        return button
    }()
    
    func statusButton(forEvent event: RCEvent) -> SDKView? {

        if let status = event.currentUser?.participantStatus {
            
            let button = self.statusButton
            if status.isAccepted {
                button.image = Self.checkMarkImage
                button.setExclusiveMenuState(.on, forMenuItemAtIndex: 0)
                button.isEnabled = true
            } else if status.isTentative {
                button.image = Self.questionMarkImage
                button.setExclusiveMenuState(.on, forMenuItemAtIndex: 1)
                button.isEnabled = true
            } else if status.isDeclined {
                button.image = Self.declineImage
                button.setExclusiveMenuState(.on, forMenuItemAtIndex: 2)
                button.isEnabled = true
            } else {
                button.image = Self.checkMarkImage
                button.isEnabled = false
            }
        
            return button
        }
        
        return nil
    }
    
    public override func updateActionButtons(_ actionButtons: inout [SDKView],
                                             forRowItem rowItem: EventListRowItem) {

        if  let event = rowItem.calendarItem as? RCEvent,
            event.hasDates,
            !event.isAllDay,
            let button = self.statusButton(forEvent: event) {
                
            actionButtons.append(button)
        }
    }
   
    override func viewWillAppear(withContent rowItem: EventListRowItem) {
        super.viewWillAppear(withContent: rowItem)
        
        if  let event = rowItem.calendarItem as? RCEvent,
            let currentUser = event.currentUser,
            currentUser.participantStatus.isTentative {
            
            self.contentViews.notAcceptedOverlay.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentViews.startCountDownLabel.outputFormatter = { _, countdown in
            return " (Event starts in \(countdown))"
        }
        
        self.contentViews.endCountDownLabel.outputFormatter = { _, countdown in
            return " (Event ends in \(countdown))"
        }
    }
}
