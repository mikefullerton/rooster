//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListViewController : TableViewController {
    
    override func createViewReloader() -> TableViewReloader? {
        return TableViewReloader(withName: DataModel.DidChangeEvent)
    }

    override func updatedViewModel() -> TableViewModelProtocol {
        return CalenderListViewModel(withCalendars: DataModel.instance.calendars,
                                     delegateCalendars: DataModel.instance.delegateCalendars)
    }
}
