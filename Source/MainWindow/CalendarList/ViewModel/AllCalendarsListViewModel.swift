//
//  CalendarSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct AllCalendersListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    private static func add(calendars: [CalendarSource: [EventKitCalendar]], to sections: inout [TableViewSectionProtocol]) {
        for source in calendars.sortedKeys {
            sections.append(CalendarSection(withSource: source, calendars:calendars[source]!))
        }
    }
    
    init(withCalendars calendars: [CalendarSource: [EventKitCalendar]],
         delegateCalendars: [CalendarSource: [EventKitCalendar]]) {
        
        var sections: [TableViewSectionProtocol] = []
        
        AllCalendersListViewModel.add(calendars: calendars, to: &sections)

        sections.append(DelegateHeaderSection())

        AllCalendersListViewModel.add(calendars: delegateCalendars, to: &sections)
        
        self.sections = sections
    }
}
