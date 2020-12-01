//
//  CalenderSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct CalendarSection : TableViewSectionProtocol {
    
    let rows:[TableViewRowProtocol]
    
    private let source: String
    private let calendars: [EventKitCalendar]
    
    init(withSource source: String,
         calendars: [EventKitCalendar]) {
        
        self.source = source
        self.calendars = calendars
        
        var rows: [CalendarRow] = []
        for calendar in calendars {
            rows.append(CalendarRow(withCalendar: calendar))
        }
        
        self.rows = rows
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return TableViewSectionAdornment(withTitle: self.source, height: 20)
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return SpacerAdornment(withHeight: 20)
    }
}

