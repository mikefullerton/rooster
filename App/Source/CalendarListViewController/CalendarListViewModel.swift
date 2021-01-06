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
    
    init(withCalendars calendars: [CalendarSource: [Calendar]]) {
        
        var sections: [TableViewSectionProtocol] = []

        for source in calendars.sortedKeys {
            
            let rowData = calendars[source]!
            
            let header = TableViewSectionAdornment(withTitle: source, height: 20)
            
            let footer = SpacerAdornment(withHeight: 20)
            
            let section = TableViewSection<Calendar, CalendarListCell>(withRowData:rowData,
                                                                               header: header,
                                                                               footer: footer)
            
            sections.append(section)
        }

        self.sections = sections
    }
}
