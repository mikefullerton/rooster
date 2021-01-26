//
//  SDKSwitch.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/25/21.
//

import Foundation
import Cocoa

class SDKSwitch : NSButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isBordered = false

        self.setButtonType(.switch)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(title: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {

        self.init(frame: CGRect.zero)
        
        self.title = title
        self.target = target
        self.action = action
        self.toolTip = toolTip
    }
    
    var isOn: Bool {
        get {
            return self.intValue == 1
        }
        set(isOn) {
            self.intValue = isOn ? 1 : 0
        }
    }

    
}
