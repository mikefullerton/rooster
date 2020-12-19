//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class AllCalendarsListViewController : EventKitTableViewController<AllCalendersListViewModel> {
    
    override func reloadViewModel() -> AllCalendersListViewModel? {
        
        let dataModel = EventKitDataModelController.dataModel
        
        return AllCalendersListViewModel(withCalendars: dataModel.calendars,
                                     delegateCalendars: dataModel.delegateCalendars)
    }
}
