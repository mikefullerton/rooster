//
//  DataModelReloader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

protocol DataModelAware : AnyObject {
    func dataModelDidReload(_ dataModel: DataModel)
}

class DataModelReloader  {
    private weak var target: DataModelAware?
    
    init(for target: DataModelAware? = nil) {
        self.target = target
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationReceived(_:)),
                                               name: DataModelController.DidChangeEvent,
                                               object: nil)
    }
    
    @objc private func notificationReceived(_ notif: Notification) {
        if let target = self.target {
            target.dataModelDidReload(DataModelController.dataModel)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

