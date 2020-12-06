//
//  EventSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct ReminderSection : TableViewSectionProtocol {
    let rows:[TableViewRowProtocol]
    
    init(withReminder reminder: EventKitReminder) {
        self.rows = [ ReminderRow(withReminder: reminder) ]
    }
    
//    var header: TableViewSectionAdornmentProtocol? {
//        return SpacerAdornment(withHeight: 10.0)
//    }
//    
//    var footer: TableViewSectionAdornmentProtocol? {
//        return DividerAdornment(withHeight: 20.0)
//    }
}
