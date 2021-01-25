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
    
    typealias DataType = Reminder
    
    private var reminder: Reminder? {
        return self.calendarItem as? Reminder
    }
        
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    func configureCell(withData reminder: Reminder, indexPath: IndexPath, isSelected: Bool) {
        self.updateCell(withCalendarItem: reminder)
    }
}
