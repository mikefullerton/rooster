//
//  EventSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct EventSection : TableViewSectionProtocol {
    let rows:[TableViewRowProtocol]
    
    init(withEvent event: EventKitEvent) {
        self.rows = [ EventRow(withEvent: event) ]
    }
    
    var header: TableViewSectionAdornmentProtocol? {
        return SpacerAdornment(withHeight: 10.0)
    }
    
    var footer: TableViewSectionAdornmentProtocol? {
        return DividerAdornment(withHeight: 20.0)
    }
}
