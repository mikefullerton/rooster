//
//  EventListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct EventListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(withEvents events: [EventKitEvent],
         reminders: [EventKitReminder]) {
        
        var sortedList:[EventKitItem] = events + reminders
        
        sortedList.sort { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
        
        var sections: [TableViewSectionProtocol] = []
        for item in sortedList {
            if let event = item as? EventKitEvent {
                let section = TableViewSection<EventKitEvent, EventListTableViewCell>(withRowData: [event])
                sections.append(section)
            }
            
            if let reminder = item as? EventKitReminder {
                let section = TableViewSection<EventKitReminder, ReminderTableViewCell>(withRowData: [reminder])
                sections.append(section)
            }
        }
        self.sections = sections
    }
}
