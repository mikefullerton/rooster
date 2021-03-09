//
//  SDKButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation

import Cocoa


public class SDKButton : NSButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

//        self.isBordered = false
//        self.contentTintColor = Theme(for: self).secondaryLabelColor
//        self.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)
    }
    
    public convenience init(title: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(title: title, image: nil, target: target, action: action, toolTip: toolTip)
    }
    
    public convenience init(title: String?,
                            image: SDKImage?,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String?) {
        
        self.init(frame: CGRect.zero)
        
        self.title = title ?? ""
        self.image = image
        self.target = target
        self.action = action
        self.toolTip = toolTip
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
