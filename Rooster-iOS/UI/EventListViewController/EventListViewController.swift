//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class EventListViewController: CalendarItemTableViewController<EventListViewModel> {
    override func provideDataModel() -> EventListViewModel? {
        EventListViewModel(withEvents: Controllers.dataModelController.dataModel.events,
                                  reminders: Controllers.dataModelController.dataModel.reminders)
    }
}
