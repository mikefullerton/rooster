//
//  EventListViewModel.swift
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

struct MenuBarEventListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(withEvents events: [Event],
         reminders: [Reminder]) {
        
        var sortedList:[CalendarItem] = events + reminders
        
        sortedList.sort { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
        
        let section = MenuBarCalendarItemsSection(withCalendarItems: sortedList)
        
        self.sections = [ section ]
    }
}

struct MenuBarCalendarItemsSection : TableViewSectionProtocol {
    var rows: [TableViewRowProtocol]
    
    var layout = TableViewSectionLayout(rowSpacing: 0, insets: SDKEdgeInsets.zero)

    init(withCalendarItems calendarItems: [CalendarItem]) {
       
        var rows: [TableViewRowProtocol] = []
        for item in calendarItems {
            if let event = item as? Event {
                rows.append(TableViewRow<Event, MenuBarEventListTableViewCell>(withData: event))
            }
            
            if let reminder = item as? Reminder {
                rows.append(TableViewRow<Reminder, MenuBarReminderTableViewCell>(withData: reminder))
            }
        }
        self.rows = rows
    }
}
