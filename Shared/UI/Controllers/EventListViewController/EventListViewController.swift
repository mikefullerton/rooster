//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class EventListViewController : CalendarItemListViewController<EventListViewModel> {
   
    override func provideDataModel() -> EventListViewModel? {
        return EventListViewModel(withEvents: AppDelegate.instance.dataModelController.dataModel.events,
                                  reminders: AppDelegate.instance.dataModelController.dataModel.reminders)
    }
}
