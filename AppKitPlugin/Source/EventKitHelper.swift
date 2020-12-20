//
//  EventKitHelper.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import EventKit

@objc class EventKitHelper: NSObject, AppKitEventKitHelper {
 
    func requestPermissionToDelegateCalendars(for eventStore: EKEventStore, completion: ((Bool, EKEventStore?, Error?) -> Void)?) {
        if completion != nil {
            completion!(false, nil, nil)
        }
    
        let sources = eventStore.delegateSources

        let delegateEventStore = EKEventStore(sources: sources)

        delegateEventStore.requestAccess(to: EKEntityType.event) { (success, error) in

            if success == false || error != nil {
                if completion != nil {
                    completion!(false, nil, error)
                }
            } else {
                if completion != nil {
                    completion!(true, delegateEventStore, nil)
                }
            }
        }
    }
    
}
