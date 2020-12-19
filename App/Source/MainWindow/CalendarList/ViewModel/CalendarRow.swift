//
//  CalenderSection.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

struct CalendarRow : TypedTableViewRowProtocol {
    
    typealias ViewClass = CalendarListCell
    
    private let calendar: EventKitCalendar
    
    init(withCalendar calendar: EventKitCalendar) {
        self.calendar = calendar
    }
        
    func willDisplay(cell: CalendarListCell) {
        cell.setCalendar(self.calendar)
    }
}
