//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import AppKit
import EventKit

extension Date {
    
    func isAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) == .orderedDescending
        return isAfter
    }
    
    func isBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) == .orderedAscending
        return isBefore
    }
    
}


class AppKitPlugin : NSObject, AppKitPluginProtocol {
    func findEvents(with calendars: [EKCalendar]!, store: EKEventStore!) -> [EKEvent]! {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        guard let today = currentCalendar.date(from: dateComponents) else {
            return []
        }
        
        guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 30, to: today) else {
            return []
        }
        
        let predicate = store.predicateForEvents(withStart: today,
                                                 end: tomorrow,
                                                 calendars: calendars)

    
        let now = Date()
        
        var events:[EKEvent] = []
        
        for event in store.events(matching: predicate) {
            
            if event.isAllDay {
                continue
            }
            
            guard let endDate = event.endDate else {
                continue
            }
            
            if event.status == .canceled {
                continue
            }
            
//            guard let title = event.title else {
//                continue
//            }

            if endDate.isAfterDate(now) {
                events.append(event)
            }
        }
        
        return events
    }
    
    func requestPermissionToDelegateCalendars(for eventStore: EKEventStore!, completion: ((Bool, EKEventStore?, Error?) -> Void)!) {
        if eventStore == nil {
            completion(false, nil, nil)
        }

        let sources = eventStore!.delegateSources

        let delegateEventStore = EKEventStore(sources: sources)

        delegateEventStore.requestAccess(to: EKEntityType.event) { (success, error) in

            if success == false || error != nil {
                completion(false, nil, error)
            } else {
                completion(true, delegateEventStore, nil)
            }
        }
    }
}
