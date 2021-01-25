//
//  LinkButton.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/20/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class LinkButton : SDKButton, Loggable {

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
