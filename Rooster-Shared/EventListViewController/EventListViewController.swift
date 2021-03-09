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

public class EventListViewController: CalendarItemListViewController {
    override public func provideDataModel() -> EventListViewModel? {
        let prefs = TodayWindowPreferences.scheduleProvider
        let factory = EventListViewModel.Factory(withPreferencesProviders: prefs)
        return EventListViewModel(withSchedule: CoreControllers.shared.scheduleController.schedule,
                                  factory: factory)
    }
}
