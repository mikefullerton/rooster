//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import Cocoa

class EventListViewController : CalendarItemTableViewController<EventListViewModel> {
    
    override func reloadViewModel() -> EventListViewModel? {
        return EventListViewModel(withEvents: AppDelegate.instance.dataModelController.dataModel.events,
                                  reminders: AppDelegate.instance.dataModelController.dataModel.reminders)
    }
}
