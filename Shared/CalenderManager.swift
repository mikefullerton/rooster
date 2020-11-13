//
//  CalenderManager.swift
//  Rooster
//
//  Created by Mike Fullerton on 11/13/20.
//

import Foundation
import EventKit


class CalendarManager {
    let store: EKEventStore
    var calendars: [EKCalendar] = []
    var events: [EKEvent] = []
    
    var chickens: AlarmSound!
    
    static var instance: CalendarManager = {
       return CalendarManager()
    }()
    
    init() {
        self.store = EKEventStore()
        self.chickens = AlarmSound(withName: .chickens) 
    }

    func playAlarmSound() {
        self.chickens.play()
    }
    
    func silenceAlarmSound() {
        self.chickens.stop()
    }
    
    func wantsCalendar(calendar: EKCalendar) -> Bool {
        if calendar.source.title == "apple.com" && calendar.title == "Apple" {
            return true
        }
        
        if calendar.source.title == "Google" && calendar.title == "Mike Fullerton" {
            return true
        }
        
        return false
    }

    func addEvents() {
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        guard let today = Calendar.current.date(from: dateComponents) else {
            return
        }
        
        guard let tomorrow: Date = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
            return
        }
        
        let predicate = self.store.predicateForEvents(withStart: today,
                                                      end: tomorrow,
                                                      calendars: self.calendars)
        
        let now = Date()
        
        for event in self.store.events(matching: predicate) {
            
            if event.isAllDay {
                continue
            }
            
            guard let startDate = event.startDate else {
                continue
            }
            
            guard let title = event.title else {
                continue
            }

            let comparison = now.compare(startDate)
            
            if comparison != .orderedDescending {
                print("\(title)")
                
                self.events.append(event)
            }
        }
    }
    
    func add(calender: EKCalendar) {
        if self.wantsCalendar(calendar: calender) {
            self.calendars.append(calender)
        }
    }
    
    
    func configureAlarms() {
        self.calendars = []
        self.events = []

        let calendars = self.store.calendars(for: .event)
        
        for calendar in calendars {
            self.add(calender: calendar)
        }
    
        self.addEvents()
    }
    
    @objc func storeChanged(_ notification: Notification) {
        self.configureAlarms()
    }
    
    func handleAccessGranted() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: self.store)
        self.configureAlarms()
    }
    
    func handleAccessDenied(error: Error?) {
        
    }
    
    func requestAccess() {
        self.store.requestAccess(to: EKEntityType.event, completion: { (success: Bool, error: Error?) in
//                print("hello! \(success), Error: \(String(describing: error))")
            if success == true {
                self.handleAccessGranted()
            } else {
                self.handleAccessDenied(error: error)
            }
        })
    }
}
