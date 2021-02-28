//
//  PreferencePanel.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/28/21.
//

import Foundation

protocol PreferencePanel {
    func resetButtonPressed()
    var toolbarButtonIdentifier: NSToolbarItem.Identifier { get }
}
