//
//  DataModelReloader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

public protocol DataModelAware : AnyObject {
    func dataModelDidReload(_ dataModel: RCCalendarDataModel)
}

public class DataModelReloader {
    
    public weak var target: DataModelAware?
    
    public init(for target: DataModelAware? = nil) {
        self.target = target
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: RCCalendarDataModelController.DidChangeEvent,
                                               object: nil)
    }
    
    @objc private func notificationReceived(_ notif: Notification) {
        if let dataModel = Controllers.dataModelController.dataModel {
            self.target?.dataModelDidReload(dataModel)
        }
    }
}

