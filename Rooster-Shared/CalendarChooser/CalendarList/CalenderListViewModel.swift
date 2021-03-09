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

public class CalenderListViewModel: ListViewModel {
    public init(withCalendarGroups calendarGroups: [CalendarGroup]) {
        var sections: [Section] = []

        let sortedGroups = calendarGroups.sorted { lhs, rhs -> Bool in
            lhs.source.compare(rhs.source, options: .caseInsensitive) == ComparisonResult.orderedAscending
        }

        for group in sortedGroups {
            let header = Adornment(withTitle: group.source)

            let sortedCalendars = group.calendars.sorted { lhs, rhs -> Bool in
                lhs.eventKitCalendar.title.compare(rhs.eventKitCalendar.title, options: .caseInsensitive) == ComparisonResult.orderedAscending
            }

            let rows = sortedCalendars.map { Row(withContent: $0, rowControllerClass: CalendarListRowController.self) }

            let section = Section(withRows: rows,
                                  header: header,
                                  footer: nil /*footer*/)

            sections.append(section)
        }

        super.init(withSections: sections)
    }
}
