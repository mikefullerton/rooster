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

class PersonalCalendarListViewController : CalendarItemListViewController<CalenderListViewModel> {

    override func provideDataModel() -> CalenderListViewModel? {
        let dataModel = Controllers.dataModelController.dataModel
        return CalenderListViewModel(withCalendars: dataModel.calendars)
    }
}
