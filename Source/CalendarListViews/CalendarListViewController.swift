//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class CalendarListViewController : TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleModelReloadEvent(_:)), name: DataModel.DidChangeEvent, object: nil)
    }

    override func updatedViewModel() -> TableViewModelProtocol {
        return CalenderListViewModel(withCalendars: DataModel.instance.calendars,
                                     delegateCalendars: DataModel.instance.delegateCalendars)
    }
}
