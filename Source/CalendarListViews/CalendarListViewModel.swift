//
//  CalendarSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct CalendarSection : TableViewSectionProtocol {
    private let source: String
    private let calendars: [EventKitCalendar]
    
    init(withSource source: String,
         calendars: [EventKitCalendar]) {
        
        self.source = source
        self.calendars = calendars
    }
    
    var rowCount: Int {
        return self.calendars.count
    }

    func row(forIndex index: Int) -> TableViewRowProtocol? {
        guard index >= 0 && index < self.calendars.count else {
            return nil
        }
            
        return CalendarRow(withCalendar: self.calendars[index])
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return TableViewSectionAdornment(withTitle: self.source, height: 20)
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return TableViewSectionAdornment(withHeight: 20)
    }
}

struct CalendarRow : TableViewRowProtocol {
    private let calendar: EventKitCalendar
    
    init(withCalendar calendar: EventKitCalendar) {
        self.calendar = calendar
    }
    
    var cellReuseIdentifer: String {
        return "CalendarRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return CalendarListCell.self
    }
    
    var height: CGFloat {
        return 24
    }
    
    func willDisplay(cell: UITableViewCell) {
        if let calenderCell = cell as? CalendarListCell {
            calenderCell.setCalendar(self.calendar)
        }
    }
}

struct CalendarSectionHeader :  TableViewSectionAdornmentProtocol {
    
    private let source: String
    
    init(withSource source: String) {
        self.source = source
    }
    
    var title: String? {
        return self.source
    }

    var view: UIView? {
        return nil;
    }
    
    var height: CGFloat {
        return 24
    }
}

struct DelegateDividerRow : TableViewRowProtocol {
    private let title: String
    
    init(withTitle title: String) {
        self.title = title
    }
    
    var cellReuseIdentifer: String {
        return "DelegateDividerRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return UITableViewCell.self
    }
    
    var height: CGFloat {
        return 100
    }
    
    func willDisplay(cell: UITableViewCell) {
        cell.textLabel?.text = self.title
    }
}

struct CalenderListViewModel : TableViewModelProtocol {
    
    private let sections: [TableViewSectionProtocol]
    
    private static func add(calendars: SourceToCalendarMap, to sections: inout [TableViewSectionProtocol]) {
        for source in calendars.sortedKeys {
            sections.append(CalendarSection(withSource: source, calendars:calendars[source]!))
        }
    }
    
    init(withCalendars calendars: SourceToCalendarMap,
         delegateCalendars: SourceToCalendarMap) {
        
        var sections: [TableViewSectionProtocol] = []
        
        CalenderListViewModel.add(calendars: calendars, to: &sections)

        sections.append(TableViewSection(withRows: [ DelegateDividerRow(withTitle: "Delegate Calendars") ]))

        CalenderListViewModel.add(calendars: delegateCalendars, to: &sections)
        
        self.sections = sections
    }
    
    var sectionCount: Int {
        return self.sections.count
    }
    
    func section(forIndex index: Int) -> TableViewSectionProtocol? {
        guard index >= 0, index < self.sections.count else {
            return nil
        }
        return self.sections[index]
    }
    
    
}
