//
//  EventKitHelper.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit
import OSLog

@objc class EventKitHelper: NSObject, AppKitEventKitHelper {
 
    private let logger = Logger(subsystem: "com.apple.rooster", category: "AppKitPlugin.EventKitHelper")
    
    func requestPermissionToDelegateCalendars(for eventStore: EKEventStore, completion: ((Bool, EKEventStore?, Error?) -> Void)?) {
        let sources = eventStore.delegateSources

        let delegateEventStore = EKEventStore(sources: sources)

        self.logger.log("EventKitHelper requesting access to delegate calendars")
        
        delegateEventStore.requestAccess(to: EKEntityType.event) { (success, error) in

            if success == false || error != nil {
                self.logger.error("Failed to be granted access to delegate calendars with error: \(error?.localizedDescription ?? "nil")")
                if completion != nil {
                    completion!(false, nil, error)
                }
            } else {
                self.logger.log("Access granted to delegate calendars")

                if completion != nil {
                    completion!(true, delegateEventStore, nil)
                }
            }
        }
    }
    
}
