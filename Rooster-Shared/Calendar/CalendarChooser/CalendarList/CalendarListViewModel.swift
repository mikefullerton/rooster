//
//  CalendarListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import RoosterCore

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

struct CalenderListViewModel : ListViewModelProtocol {
    
    let sections: [ListViewSectionDescriptor]
    
    init(withCalendars calendars: [CalendarSource: [RCCalendar]]) {
        
        var sections: [ListViewSectionDescriptor] = []

        for source in calendars.sortedKeys {
            
            let rowContent = calendars[source]!
            
            let header = ListViewSectionAdornment(withTitle: source)
            
//            let footer = SpacerAdornment(withHeight: 20)
            
            let rows = rowContent.map { ListViewRowDescriptor<RCCalendar, CalendarListRowController>(withContent: $0)}
            
            let section = ListViewSectionDescriptor(withRows: rows,
                                          header: header,
                                          footer: nil /*footer*/)
            
            sections.append(section)
        }

        self.sections = sections
    }
}
