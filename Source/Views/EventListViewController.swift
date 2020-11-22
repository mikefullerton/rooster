//
//  EventListViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation
import UIKit

class EventListViewController : TableViewController {
    
    override func createViewReloader() -> TableViewReloader? {
        return TableViewReloader(withName: DataModel.DidChangeEvent)
    }

    override func updatedViewModel() -> TableViewModelProtocol {
        let events = DataModel.instance.events.map { EventRow(withEvent: $0) }
        let section = TableViewSection(withRows: events)
        return TableViewModel(withSections: [ section ])
    }
}
