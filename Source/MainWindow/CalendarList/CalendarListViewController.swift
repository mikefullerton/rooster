//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListViewController : EventKitTableViewController<CalenderListViewModel> {
    
    override func reloadViewModel() -> CalenderListViewModel? {
        
        let dataModel = EventKitDataModelController.dataModel
        
        return CalenderListViewModel(withCalendars: dataModel.calendars,
                                     delegateCalendars: dataModel.delegateCalendars)
    }
}
