//
//  Reloable.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

public protocol Reloadable : AnyObject {
    func reloadData()
}

open class Reloader : EventNotifier {
    
    public weak var reloadable: Reloadable?
    
    public init(withNotificationName name: Notification.Name,
                object: AnyObject?,
                for reloadable: Reloadable? = nil) {
        
        self.reloadable = reloadable
        super.init(withName: name,
                   object: object)
    }
    
    public convenience init(withNotificationName name: Notification.Name,
                     for reloadable: Reloadable? = nil) {
        self.init(withNotificationName: name,
                  object: nil,
                  for: reloadable)
    }
    
    @objc override func notificationReceived(_ notif: Notification) {
        if self.reloadable != nil {
            self.reloadable!.reloadData()
        }
    }
}

