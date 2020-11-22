//
//  DataModel+EventUtilities.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/21/20.
//

import Foundation

extension DataModel {
    
    var nextEventTime: Date? {
        
        let now = Date()
        
        for event in self.events {
            if event.startDate.isAfterDate(now) {
                return event.startDate
            }

            if event.startDate.isAfterDate(now) {
                return event.endDate
            }
        }
        
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        if let today = currentCalendar.date(from: dateComponents),
           let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 1, to: today) {
            
            return tomorrow
        }
        
        return nil
    }
    
    func stopAlarmsIfNeeded() {
        var events:[EventKitEvent] = []

        for event in self.events {
            if event.isFiring && (!event.isInProgress || event.hasFired) {
                events.append(event.updatedEvent(isFiring: false, hasFired: true))
            }
        }

        if events.count > 0 {
            DispatchQueue.main.async {
                self.update(someEvents: events)
            }
        }
    }

    func fireAlarmsIfNeeded() {
        var events: [EventKitEvent] = []

        for event in self.events {
            if event.isInProgress &&
                event.hasFired == false &&
                event.isFiring == false {
                events.append(event.updatedEvent(isFiring: true, hasFired: false))
            }
        }

        if events.count > 0 {
            DispatchQueue.main.async {
                self.update(someEvents: events)
            }
        }
    }

}
