//
//  PreferencesTableViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/2/20.
//

import Foundation
import UIKit

class PreferencesTableViewController : EventKitTableViewController<PreferencesTableViewModel> {
    
    override func reloadViewModel() -> PreferencesTableViewModel? {
        return PreferencesTableViewModel(preferences: PreferencesController.instance.preferences)
    }
}
