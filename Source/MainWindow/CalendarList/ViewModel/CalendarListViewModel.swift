//
//  CalendarListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

struct CalenderListViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    init(withCalendars calendars: [CalendarSource: [EventKitCalendar]]) {
        
        var sections: [TableViewSectionProtocol] = []

        for source in calendars.sortedKeys {
            sections.append(CalendarSection(withSource: source, calendars:calendars[source]!))
        }

        self.sections = sections
    }
}
