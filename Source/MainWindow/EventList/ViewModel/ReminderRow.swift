//
//  EventRow.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct ReminderRow : TypedTableViewRowProtocol {
    
    typealias ViewClass = ReminderTableViewCell
    
    private let reminder: EventKitReminder
    
    init(withReminder reminder: EventKitReminder) {
        self.reminder = reminder
    }
        
    func willDisplay(cell: ReminderTableViewCell) {
        cell.setReminder(self.reminder)
    }
}
