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
        
        let sortedList = RCCalendarDataModel.sortCalendarItems(events + reminders)
        
        var rows:[AbstractListViewRowDescriptor] = []
        
        if sortedList.isEmpty {
            rows.append(ListViewRowDescriptor<NoMeetingsModelObject, MenuBarNoMeetingsListViewCell>(withContent: NoMeetingsModelObject()))
        } else {
            for item in sortedList {
                if let event = item as? RCEvent {
                    rows.append(ListViewRowDescriptor<RCCalendarItem, MenuBarEventListListViewCell>(withContent: event))
                }
                
                if let reminder = item as? RCReminder {
                    rows.append(ListViewRowDescriptor<RCCalendarItem, MenuBarReminderListViewCell>(withContent: reminder))
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
