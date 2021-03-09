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
    
    init(withEvents events: [RCEvent],
         reminders: [RCReminder]) {
        
        let sortedList = RCCalendarDataModel.sortCalendarItems(events + reminders)
        
        var sections: [TableViewSectionProtocol] = []
        for item in sortedList {
            if let event = item as? RCEvent {
                let section = TableViewSection<RCEvent, EventListTableViewCell>(withRowData: [event])
                sections.append(section)
            }
            
            if let reminder = item as? RCReminder {
                let section = TableViewSection<RCReminder, ReminderTableViewCell>(withRowData: [reminder])
                sections.append(section)
            }
        }
        self.sections = sections
    }
}
