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

struct MenuBarItemViewModel : ListViewModelProtocol {
    
    
    let sections: [ListViewSectionDescriptor]
    
    init(withEvents events: [RCEvent],
         reminders: [RCReminder]) {
        
        var sortedList:[RCCalendarItem] = events + reminders
        
        sortedList.sort { lhs, rhs in
            return lhs.alarm.startDate.isBeforeDate(rhs.alarm.startDate)
        }
       
        var rows:[AbstractListViewRowDescriptor] = []
        
        if sortedList.count == 0 {
            rows.append(ListViewRowDescriptor<NoMeetingsModelObject, MenuBarNoMeetingsListViewCell>(withContent: NoMeetingsModelObject()))
        } else {
            for item in sortedList {
                if let event = item as? RCEvent {
                    rows.append(ListViewRowDescriptor<RCEvent, MenuBarEventListListViewCell>(withContent: event))
                }
                
                if let reminder = item as? RCReminder {
                    rows.append(ListViewRowDescriptor<RCReminder, MenuBarReminderListViewCell>(withContent: reminder))
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

