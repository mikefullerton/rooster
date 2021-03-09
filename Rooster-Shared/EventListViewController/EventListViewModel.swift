//
//  EventListViewModel.swift
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

struct NoMeetingsModelObject {
    
}

struct EventListRowItem {
    var calendarItem: RCCalendarItem
    var startDate: Date?
    var endDate: Date?
}

struct EventListViewModel : ListViewModelProtocol {
    
    let sections: [ListViewSectionDescriptor]
    
    init(withEvents events: [RCEvent],
         reminders: [RCReminder]) {
        
        let sortedList = RCCalendarDataModel.sortCalendarItems(events + reminders)
        
        var rows: [AbstractListViewRowDescriptor] = []
        
        if sortedList.isEmpty {
            rows.append(ListViewRowDescriptor<NoMeetingsModelObject, NoMeetingsListViewCell>(withContent: NoMeetingsModelObject()))
        } else {
            
            var lastDate: Date?
            
            for item in sortedList {

                if let startDate = item.alarm.startDate,
                    lastDate == nil || lastDate!.isSameDay(asDate: startDate) == false {
                    rows.append(ListViewRowDescriptor<Date, DayBannerRow>(withContent: startDate))

                    lastDate = startDate
                }

                
                if let event = item as? RCEvent {
                    
                    let rowItem = EventListRowItem(calendarItem:event, startDate: event.alarm.startDate, endDate: event.alarm.endDate)
                    
                    rows.append(ListViewRowDescriptor<EventListRowItem, EventListListViewCell>(withContent: rowItem))
                }
                
                if let reminder = item as? RCReminder {
                    let rowItem = EventListRowItem(calendarItem:reminder, startDate: reminder.alarm.startDate, endDate: reminder.alarm.endDate)

                    rows.append(ListViewRowDescriptor<EventListRowItem, ReminderListViewCell>(withContent: rowItem))
                }
            }
        }
    
        self.sections = [ ListViewSectionDescriptor(withRows: rows) ]
    }
}

