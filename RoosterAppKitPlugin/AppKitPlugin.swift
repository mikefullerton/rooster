//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import AppKit
import EventKit

class AppKitPlugin : NSObject, AppKitPluginProtocol {
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
