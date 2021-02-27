//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class EventListViewController : CalendarItemListViewController<EventListViewModel> {
   
    override func provideDataModel() -> EventListViewModel? {
        return EventListViewModel(withEvents: Controllers.dataModelController.dataModel.events,
                                  reminders: Controllers.dataModelController.dataModel.reminders)
    }
}
