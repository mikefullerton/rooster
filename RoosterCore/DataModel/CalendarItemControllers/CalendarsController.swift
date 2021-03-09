//
//  CalendarsController.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import EventKit

public class CalendarsController: AbstractCalendarController {
    
    public func save(calendar: RCCalendar) {
        
        if calendar.hasChanges {
            Controllers.dataModel.update(calendar: calendar)
            
            let ekCalendar = calendar.updateEKCalendar()
            
            if ekCalendar.hasChanges {
                let eventStore = calendar.ekEventStore
                
                do {
                    try eventStore.saveCalendar(ekCalendar, commit: true)

                } catch {
                    self.showSaveError(forItem:calendar,
                                       informativeText: "",
                                       error:error)
                }
            }
        }
    }
}

public protocol MutableCalendarDelegate: AnyObject {
    func calendarDidChange(_ calender: RCCalendar)
}

public class MutableCalendar {
    
    public weak var delegate: MutableCalendarDelegate?
    
    public var calendar: RCCalendar? {
        didSet {
            if  oldValue != nil,
                let newCalendar = calendar,
                oldValue != newCalendar {
                
                Controllers.calendar.save(calendar: newCalendar)
                    
                self.delegate?.calendarDidChange(newCalendar)
            }
        }
    }
    
    public init(withCalendar calendar: RCCalendar) {
        self.calendar = calendar
    }
}

extension RCCalendar {
    func updateEKCalendar() -> EKCalendar {
        self.ekCalendar.title = self.title
        self.ekCalendar.cgColor = self.cgColor
        
        return self.ekCalendar
    }
}
