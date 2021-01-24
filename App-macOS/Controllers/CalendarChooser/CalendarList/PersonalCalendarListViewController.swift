//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import Cocoa

class PersonalCalendarListViewController : CalendarItemTableViewController<CalenderListViewModel> {

    override func reloadViewModel() -> CalenderListViewModel? {
        let dataModel = AppDelegate.instance.dataModelController.dataModel
        return CalenderListViewModel(withCalendars: dataModel.calendars)
    }
}
