//
//  EventListViewModel.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

struct EventRow : TableViewRowProtocol {
    private let event: EventKitEvent
    
    init(withEvent event: EventKitEvent) {
        self.event = event
    }
    
    var cellReuseIdentifer: String {
        return "EventRow"
    }
    
    var cellClass: UITableViewCell.Type {
        return EventListTableViewCell.self
    }
    
    var height: CGFloat {
        return 24
    }
    
    func willDisplay(cell: UITableViewCell) {
        if let calenderCell = cell as? EventListTableViewCell {
            calenderCell.setEvent(self.event)
        }
    }
}

