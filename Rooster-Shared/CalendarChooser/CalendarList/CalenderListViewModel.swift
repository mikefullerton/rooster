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
        super.init()

        var sections: [Section] = []

        let sortedGroups = calendarGroups.sorted { lhs, rhs -> Bool in
            lhs.source.compare(rhs.source, options: .caseInsensitive) == ComparisonResult.orderedAscending
        }

        for group in sortedGroups {
            let toggle = Switch(title: group.source, target: self, action: #selector(checkBoxChecked(_:)))
            toggle.userInfo = group
            toggle.allowsMixedState = true

            let enabledCount = group.enabledCount

            if enabledCount == group.calendars.count {
                toggle.state = .on
            } else if enabledCount == 0 {
                toggle.state = .off
            } else {
                toggle.state = .mixed
            }

//            print("Group: \(group.source), count: \(group.calendars.count), enabled count: \(enabledCount), toggle state = \(String(describing: toggle.state))")

            let header = Adornment(withCustomView: toggle)

            let sortedCalendars = group.calendars.sorted { lhs, rhs -> Bool in
                lhs.title.compare(rhs.title, options: .caseInsensitive) == ComparisonResult.orderedAscending
            }

            let rows = sortedCalendars.map { Row(withContent: $0, rowControllerClass: CalendarListRowController.self) }

            let section = Section(withRows: rows,
                                  header: header,
                                  footer: nil /*footer*/)

            sections.append(section)
        }

        self.sections = sections

        self.preferredSize = CGSize(width: 500, height: NSView.noIntrinsicMetric)
    }

    @objc func checkBoxChecked(_ checkbox: SDKButton) {
        if let calendarGroup = checkbox.userInfo as? CalendarGroup {
            var foundEnabled = false

            for calendar in calendarGroup.calendars where calendar.isEnabled {
                foundEnabled = true
                break
            }

            let newEnabled = !foundEnabled

            var newCalendars: [ScheduleCalendar] = []
            for oldCalendar in calendarGroup.calendars where oldCalendar.isEnabled != newEnabled {
                var newCalendar = oldCalendar
                newCalendar.isEnabled = newEnabled

                newCalendars.append(newCalendar)
            }

            if !newCalendars.isEmpty {
                CoreControllers.shared.scheduleController.update(calendars: newCalendars) { _, _, _ in
                }
            }
        }
    }
}
