//
//  DelegateCalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation

import Cocoa

class DelegateCalendarListViewController : CalendarItemTableViewController<CalenderListViewModel> {
    
    override func reloadViewModel() -> CalenderListViewModel? {
        let dataModel = AppDelegate.instance.dataModelController.dataModel
        return CalenderListViewModel(withCalendars: dataModel.delegateCalendars)
    }
}
