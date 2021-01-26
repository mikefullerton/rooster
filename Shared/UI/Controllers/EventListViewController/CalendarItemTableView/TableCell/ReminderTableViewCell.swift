//
//  ReminderTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class ReminderTableViewCell : CalendarItemTableViewCell, TableViewRowCell {
    
    typealias ContentType = Reminder
    
    private var reminder: Reminder? {
        return self.calendarItem as? Reminder
    }
        
    func viewWillAppear(withContent content: Reminder) {
        self.updateCell(withCalendarItem: content)
    }
}
