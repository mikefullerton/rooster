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

class ReminderListViewCell : CalendarItemListViewCell<RCReminder> {
    
    override var imageButtonIcon: SDKImage? {
        let config = NSImage.SymbolConfiguration(scale: .medium)
        return NSImage(systemSymbolName: "list.bullet", accessibilityDescription: "Reminder")?.withSymbolConfiguration(config)
    }
 
    override var itemTypeString: String {
        return "Reminder"
    }
}
