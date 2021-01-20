//
//  LinkButton.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation
import Cocoa

class LinkButton : NSButton, Loggable {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect);

//        setHighlightedColors();
    }
    
    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set(isHighlighted) {
            super.isHighlighted = isHighlighted
            
            self.logger.log("is highlighted: \(isHighlighted)")
        }
    }
    
}
