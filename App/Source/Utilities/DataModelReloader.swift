//
//  DataModelReloader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

protocol DataModelAware : AnyObject {
    func dataModelDidReload(_ dataModel: EventKitDataModel)
}

class DataModelReloader  {
    private weak var target: DataModelAware?
    
    init(for target: DataModelAware? = nil) {
        self.target = target
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: EventKitDataModelController.DidChangeEvent,
                                               object: nil)
    }
    
    @objc private func notificationReceived(_ notif: Notification) {
        if let target = self.target {
            target.dataModelDidReload(EventKitDataModelController.dataModel)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

