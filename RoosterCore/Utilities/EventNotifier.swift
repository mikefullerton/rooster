//
//  EventNotification.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation

open class EventNotifier {
    private let name: Notification.Name
  
    public init(withName name: Notification.Name, object: AnyObject?) {
        self.name = name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: name,
                                               object: object)
    }
    
    @objc func notificationReceived(_ notif: Notification) {
    }
}

