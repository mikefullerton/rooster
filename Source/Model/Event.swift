//
//  Event.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/15/20.
//

import Foundation
import EventKit

struct Event {
    
    let EKEvent: EKEvent
    let identifier: String
    let isSubscribed: Bool
    
    init(withEvent EKEvent: EKEvent,
         subscribed: Bool) {
        self.identifier = EKEvent.eventIdentifier
        self.EKEvent = EKEvent
        self.isSubscribed = subscribed
    }
    
    
    
}
