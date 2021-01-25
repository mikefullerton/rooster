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
    typealias DataType = Event
    
    private var event: Event? {
        return self.calendarItem as? Event
    }
 
    static var cellHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    func configureCell(withData event: Event, indexPath: IndexPath, isSelected: Bool) {
        self.updateCell(withCalendarItem: event)
    }
    
}
