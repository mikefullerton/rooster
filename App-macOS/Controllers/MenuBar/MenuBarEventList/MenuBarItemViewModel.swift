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

struct MenuBarItemViewModel : ListViewModelProtocol {
    
    
    let sections: [ListViewSectionDescriptor]
    
    init(withEvents events: [Event],
         reminders: [Reminder]) {
        
        var sortedList:[CalendarItem] = events + reminders
        
        sortedList.sort { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
       
        var rows:[AbstractListViewRowDescriptor] = []
        
        if sortedList.count == 0 {
            rows.append(ListViewRowDescriptor<NoMeetingsModelObject, MenuBarNoMeetingsListViewCell>(withContent: NoMeetingsModelObject()))
        } else {
            for item in sortedList {
                if let event = item as? Event {
                    rows.append(ListViewRowDescriptor<Event, MenuBarEventListListViewCell>(withContent: event))
                }
                
                if let reminder = item as? Reminder {
                    rows.append(ListViewRowDescriptor<Reminder, MenuBarReminderListViewCell>(withContent: reminder))
                }
            }
        }
        
        rows.append(ListViewRowDescriptor<MenuBarMenuChoice, MenuBarMenuChoiceView>(withContent: MenuBarMenuChoice(selector: #selector(AppDelegate.showPreferences(_:)),
                                                                                                                   title: "Preferences…",
                                                                                                                   systemSymbolName: "gearshape")))

        rows.append(ListViewRowDescriptor<MenuBarMenuChoice, MenuBarMenuChoiceView>(withContent: MenuBarMenuChoice(selector: #selector(AppDelegate.fileRadar(_:)),
                                                                                                                   title: "File Radar…",
                                                                                                                   systemSymbolName: "ladybug")))

        self.sections = [ ListViewSectionDescriptor(withRows: rows) ]
    }
}

