//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class PersonalCalendarListViewController: CalendarListViewController {
    override public func provideDataModel() -> CalenderListViewModel? {
        CalenderListViewModel(withCalendarGroups: CoreControllers.shared.scheduleController.schedule.calendars.calendarGroups)
    }

    override public func toggleAll() {
        CoreControllers.shared.scheduleController.toggleAllPersonalCalendars()
    }
}
