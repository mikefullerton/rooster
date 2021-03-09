//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

class PersonalCalendarListViewController: CalendarItemTableViewController<CalenderListViewModel> {
    override func reloadViewModel() -> CalenderListViewModel? {
        let dataModel = Controllers.dataModelController.dataModel
        return CalenderListViewModel(withCalendars: dataModel.calendars)
    }
}
