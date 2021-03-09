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

open class MenuBarItemViewController: CalendarItemListViewController {
    override open func provideDataModel() -> ListViewModel? {
        let dateRange = DateRange(startDate: Date.midnightToday, endDate: Date.endOfToday)
        let factory = EventListViewModel.Factory(withPreferencesProviders: MenuBarPreferences.scheduleProvider,
                                                 dateRange: dateRange)
        let schedule = CoreControllers.shared.scheduleController.schedule

        return EventListViewModel(withSchedule: schedule, factory: factory)
    }

    override public func createScrollView() -> NSScrollView? {
        nil
    }
}
