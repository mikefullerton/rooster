//
//  DataModelReloader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class DataModelReloader : Reloader {
    
    init(for reloadable: Reloadable) {
        super.init(withNotificationName: EventKitDataModelController.DidChangeEvent,
                   object: nil,
                   for: reloadable)
    }
}
