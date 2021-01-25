//
//  SDKButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import Cocoa


class SDKButton : NSButton {
    
    override init(frame: CGRect) {
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

class SDKImageButton: SDKButton {
    
    var normalImage: SDKImage?
    var highlightedImage: SDKImage?
    
//    var imageView: NSImageView
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isBordered = false
        self.setButtonType(.momentaryPushIn)
//        self.symbolConfiguration =
    }
    
    public convenience init(title: String?,
                            image: SDKImage,
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
    
    public convenience init(image: NSImage,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(title: nil, image: image, target: target, action: action, toolTip: toolTip)
    }
        
    func systemImage(named systemImageName: String, tint: SDKColor?) -> SDKImage? {
        if let image = SDKImage(systemSymbolName: systemImageName, accessibilityDescription: toolTip),
           let symbol = image.withSymbolConfiguration(SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)) {
        
            if tint != nil {
                return symbol.tint(color: tint!)
            }
            
            return symbol
        }
        
        return nil
    }
    
    public convenience init(systemImageName: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(frame: CGRect.zero)
        
        self.normalImage = self.systemImage(named: systemImageName, tint: SDKColor.red)
        
        self.highlightedImage = self.systemImage(named: "calendar", tint: SDKColor.red)
        
        self.image = self.normalImage
        self.target = target
        self.action = action
        self.toolTip = toolTip
    }
    
    public convenience init(imageName: String,
                            target: AnyObject?,
                            action: Selector?,
                            toolTip: String) {
        
        self.init(frame: CGRect.zero)

        self.image = SDKImage(named: imageName)
        self.target = target
        self.action = action
        self.toolTip = toolTip
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // I can't believe I have to write this code
    override func mouseDown(with event: NSEvent) {
        self.isHighlighted = true
        while true {
            let event = self.window?.nextEvent(matching: [ .leftMouseUp, .leftMouseDragged, .mouseExited, .mouseExited ])
            let mouseLoc = self.convert((event?.locationInWindow)!, from: nil)
            let isInside = self.bounds.contains(mouseLoc)
            self.isHighlighted = isInside
            if event?.type == .leftMouseUp {
                
                if isInside {
                    self.performClick(self)
                }
                
                self.isHighlighted = false
                break
            }
        }
    }
  
    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set(highlighted) {
            
            super.isHighlighted = highlighted
            
            if highlighted {
                self.image = self.highlightedImage
                self.cell?.image = self.highlightedImage
            } else {
                self.image = self.normalImage
                self.cell?.image = self.normalImage
            }
            self.invalidateIntrinsicContentSize()
            self.needsLayout = true
            self.layout()
            self.needsDisplay = true
            self.display()
            
            print("highlighted changed to: \(highlighted)")
        }
    }
}

class SDKSwitch : SDKButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

//        self.isBordered = false
//        self.contentTintColor = Theme(for: self).secondaryLabelColor
//        self.symbolConfiguration = SDKImage.SymbolConfiguration(pointSize: 18, weight: .medium)
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
