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

struct EventListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(withEvents events: [Event],
         reminders: [Reminder]) {
        
        var sortedList:[CalendarItem] = events + reminders
        
        sortedList.sort { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
        
        var sections: [TableViewSectionProtocol] = []
        for item in sortedList {
            if let event = item as? Event {
                let section = TableViewSection<Event, EventListTableViewCell>(withRowData: [event])
                sections.append(section)
            }
            
            if let reminder = item as? Reminder {
                let section = TableViewSection<Reminder, ReminderTableViewCell>(withRowData: [reminder])
                sections.append(section)
            }
        }
        self.sections = sections
    }
}
