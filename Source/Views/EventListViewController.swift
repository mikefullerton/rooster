//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class EventListViewController : TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleModelReloadEvent(_:)), name: DataModel.DidChangeEvent, object: nil)
   }

    override func updatedViewModel() -> TableViewModelProtocol {
        let events = DataModel.instance.events.map { EventRow(withEvent: $0) }
        let section = TableViewSection(withRows: events)
        return TableViewModel(withSections: [ section ])
    }
}
