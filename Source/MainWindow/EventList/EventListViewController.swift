//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class EventListViewController : EventKitTableViewController<EventListViewModel> {
    
    override func reloadViewModel() -> EventListViewModel? {
        return EventListViewModel(withEvents: EventKitDataModelController.dataModel.events)
    }
}
