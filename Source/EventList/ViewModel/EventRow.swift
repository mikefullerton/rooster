//
//  EventRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct EventRow : TypedTableViewRowProtocol {
    typealias ViewClass = EventListTableViewCell
    
    private let event: EventKitEvent
    
    init(withEvent event: EventKitEvent) {
        self.event = event
    }
        
    func willDisplay(cell: EventListTableViewCell) {
        cell.setEvent(self.event)
    }
}
