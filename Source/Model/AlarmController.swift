//
//  AlarmController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation

protocol AlarmControllerDelegate : AnyObject {
    func alarmControllerDidRequestCalendarAccess(_ alarmController: AlarmController, success:Bool, error: Error?)
}

class AlarmController {
    
    static let instance = AlarmController()
    
    weak var delegate: AlarmControllerDelegate?
    
    var calendarAccessError: Error?
    var hasCalendarAccess: Bool
    
    init() {
        self.calendarAccessError = nil
        self.hasCalendarAccess = false
    }
    
    func start() {
        CalendarManager.instance.requestAccess { (success, error) in
            DispatchQueue.main.async {
                self.hasCalendarAccess = success
                self.calendarAccessError = error

                if self.delegate != nil {
                    self.delegate!.alarmControllerDidRequestCalendarAccess(self, success: success, error: error)
                }
            }
        }
    }
}
