//
//  DataModelReloader.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation

class PreferencesReloader : Reloader {
    
    init(for reloadable: Reloadable) {
        super.init(withNotificationName: PreferencesController.DidChangeEvent,
                   object: nil,
                   for: reloadable)
    }
}
