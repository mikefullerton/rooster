//
//  CalendarItemTableViewCell+MenuBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

extension CalendarItemTableViewCell {
    func updateForMenuBar() {
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor
    }
    
}
