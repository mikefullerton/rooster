//
//  DelegateCalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

import UIKit

class DelegateCalendarListViewController : CalendarItemTableViewController<CalenderListViewModel> {
    
    override func provideDataModel() -> CalenderListViewModel? {
        let dataModel = Controllers.dataModelController.dataModel
        return CalenderListViewModel(withCalendars: dataModel.delegateCalendars)
    }
}
