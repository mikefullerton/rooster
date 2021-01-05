//
//  CalendarListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import UIKit

class CalendarListViewController : EventKitTableViewController<CalenderListViewModel> {
    
    override func reloadViewModel() -> CalenderListViewModel? {
        
        let dataModel = EventKitDataModelController.dataModel
        
        return CalenderListViewModel(withCalendars: dataModel.calendars)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
