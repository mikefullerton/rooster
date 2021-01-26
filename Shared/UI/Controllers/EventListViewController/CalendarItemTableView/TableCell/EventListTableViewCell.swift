//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class EventListTableViewCell : CalendarItemTableViewCell, TableViewRowCell {
    typealias ContentType = Event
    
    private var event: Event? {
        return self.calendarItem as? Event
    }

    func viewWillAppear(withContent content: Event) {
        self.updateCell(withCalendarItem: content)
    }
}
