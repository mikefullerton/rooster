//
//  EventNotification.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation

class EventNotifier {
    private let name: Notification.Name
  
    init(withName name: Notification.Name, object: AnyObject?) {
        self.name = name
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: name,
                                               object: object)
    }
    
    @objc func notificationReceived(_ notif: Notification) {
    }
}


// the problem with this is it would be super easy to create memory cycles

//class BlockEventNotifier {
//
//    private let name: Notification.Name
//    private let callback: () -> Void
//
//    convenience init(withName name: Notification.Name, callback: @escaping () -> Void ) {
//        self.init(withName: name, object: nil, callback: callback)
//    }
//
//    init(withName name: Notification.Name, object: AnyObject?, callback: @escaping () -> Void ) {
//        self.name = name
//        self.callback = callback
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(notificationReceived(_:)),
//                                               name: AppController.CalendarDidAuthenticateEvent, object: object)
//    }
//
//    @objc func notificationReceived(_ notif: Notification) {
//        self.callback()
//    }
//
//}

