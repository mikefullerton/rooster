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

public class EventListViewController: CalendarItemListViewController<EventListViewModel> {
    override public func provideDataModel() -> EventListViewModel? {
        EventListViewModel(withSchedule: CoreControllers.shared.scheduleController.schedule)
    }
}
