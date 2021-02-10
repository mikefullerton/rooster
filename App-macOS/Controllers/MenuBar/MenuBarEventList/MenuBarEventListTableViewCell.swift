//
//  MenuBarEventListTableView.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import Cocoa

class MenuBarEventListTableViewCell: EventListTableViewCell {
    override func loadView() {
        super.loadView()
        self.updateForMenuBar()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        self.highlightState = .forSelection
        
        self.logger.log("mouse entered: \(NSStringFromRect(self.view.frame))")
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        self.highlightState = .none
        self.logger.log("mouse exited: \(NSStringFromRect(self.view.frame))")
    }
}
