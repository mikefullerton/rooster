//
//  NSMenuItem+Utilities.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Foundation
import Cocoa

extension NSMenuItem {
 
    public convenience init(title: String,
                            image: NSImage,
                            target: AnyObject?,
                            action: Selector?,
                            keyEquivalent charCode: String = "",
                            tag: Int = 0) {
        
        self.init()
        
        self.title = title
        self.image = image
        self.target = target
        self.action = action
        self.keyEquivalent = keyEquivalent
        self.tag = tag
    }
    
    public convenience init(title: String,
                            target: AnyObject?,
                            action: Selector?,
                            keyEquivalent charCode: String = "",
                            tag: Int = 0) {
        
        self.init()
        
        self.title = title
        self.image = image
        self.target = target
        self.action = action
        self.keyEquivalent = keyEquivalent
        self.tag = tag
    }
}
