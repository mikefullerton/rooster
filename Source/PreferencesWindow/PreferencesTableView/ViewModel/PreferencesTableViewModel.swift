//
//  CalendarSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct PreferencesTableViewModel : TableViewModelProtocol {
    
    let sections: [TableViewSectionProtocol]
    
    let preferences: Preferences
    
    init(preferences: Preferences) {
        self.preferences = preferences
        
        self.sections = []
    }
    
//    private static func add(calendars: SourceToCalendarMap, to sections: inout [TableViewSectionProtocol]) {
//        for source in calendars.sortedKeys {
//            sections.append(CalendarSection(withSource: source, calendars:calendars[source]!))
//        }
//    }
//    
//    init(withCalendars calendars: SourceToCalendarMap,
//         delegateCalendars: SourceToCalendarMap) {
//        
//        var sections: [TableViewSectionProtocol] = []
//        
//        CalenderListViewModel.add(calendars: calendars, to: &sections)
//
//        sections.append(DelegateHeaderSection())
//
//        CalenderListViewModel.add(calendars: delegateCalendars, to: &sections)
//        
//        self.sections = sections
//    }
}
