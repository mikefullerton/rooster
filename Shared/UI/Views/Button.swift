//
//  EmptyButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation
import AppKit

class Button : MouseTrackingView {
    
    private(set) weak var target: AnyObject? = nil
    private(set) var action:Selector? = nil
    
    var isEnabled: Bool = true {
        didSet {
            self.mouseStateDidChange()
        }
    }
    
    private(set) var contentView: NSView?
    
    var contentViewAlignment: SubviewAlignment = .center
    
    init(withContentView view: NSView) {
        super.init(frame: CGRect.zero)
        
        self.setContentView(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setContentView(_ view: SDKView) {
        guard view != self.contentView else {
            return
        }
        
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }
        self.contentView = view
        self.addSubview(view)
        
        self.setPositionalContraints(forSubview: view, alignment: self.contentViewAlignment )
        self.setFillInParentConstraints(forSubview: view)
    
        self.invalidateIntrinsicContentSize()
        
        self.mouseStateDidChange()
    }
    
    func setTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
    
    override func mouseTrackingView(_ view: MouseTrackingView,
                                    mouseUpAtLocation: CGPoint,
                                    withEvent event: NSEvent) {
        
        if  self.isEnabled,
            let target = self.target,
            let action = self.action {
            let _ = target.perform(action, with: self)
        }
    }

    override func mouseStateDidChange() {
        if self.isEnabled == false {
            self.drawButtonDisabled()
        } else {
            if self.isMouseInside {
                if self.isMouseDown {
                    self.drawButtonPressed()
                } else {
                    self.drawButtonMouseOver()
                }
            } else {
                self.drawButtonIdle()
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if let view = self.contentView {
            let size = view.fittingSize
            print("intrinsic size: \(NSStringFromSize(size))")
            return size
        }
        
        return CGSize.zero
    }
    
    var pressedColor: SDKColor = NSColor.blue
    
    func drawButtonPressed() {
        if let view = self.contentView as? SDKImageView {
//            view.alphaValue = 0.6
            
            view.contentTintColor = self.pressedColor
            
        }
        
        if let view = self.contentView as? SDKTextField {
            view.textColor = self.pressedColor
        }
    }
    
    func drawButtonIdle() {
        if let view = self.contentView as? SDKImageView {
            view.contentTintColor = nil
        }
        
        if let view = self.contentView as? SDKTextField {
            view.textColor = nil
        }
    }

    func drawButtonDisabled() {
        if let view = self.contentView {
            view.alphaValue = 0.6
        }
    }

    func drawButtonMouseOver() {
        
    }
    
}
