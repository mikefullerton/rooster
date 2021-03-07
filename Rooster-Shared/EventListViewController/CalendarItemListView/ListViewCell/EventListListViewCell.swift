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

class EventListListViewCell : CalendarItemListViewCell<RCEvent> {
    override var imageButtonIcon: SDKImage? {
        let config = NSImage.SymbolConfiguration(scale: .small)
        return NSImage(systemSymbolName: "person.2", accessibilityDescription: "Reminder")?.withSymbolConfiguration(config)
    }

}
