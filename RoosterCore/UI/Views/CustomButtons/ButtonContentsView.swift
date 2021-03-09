//
//  ButtonContentsContainerView.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif



open class ButtonContentsView : AnimateableView, AbstractButtonContentView {
    public let imageView: NSImageView?
    public let textField: NSTextField?
    public let imagePosition: SDKView.Position
    public let spacing: CGFloat
    
    public init(withImageView imageView: NSImageView,
                textField: NSTextField,
                imagePosition: SDKView.Position,
                spacing: CGFloat) {
        self.imageView = imageView
        self.textField = textField
        self.imagePosition = imagePosition
        self.spacing = 0
        super.init(frame: CGRect.zero)
        self.addContentViews()
    }
    
    public init(withImageView imageView: NSImageView) {
        self.imageView = imageView
        self.textField = nil
        self.imagePosition = .center
        self.spacing = 0
        super.init(frame: CGRect.zero)
        self.addContentViews()
    }

    public init(withTextField textField: NSTextField) {
        self.textField = textField
        self.imageView = nil
        self.imagePosition = .center
        self.spacing = 0
        super.init(frame: CGRect.zero)
        self.addContentViews()
    }
    
    public required init?(coder: NSCoder) {
        self.textField = nil
        self.imageView = nil
        self.imagePosition = .center
        self.spacing = 0
        super.init(coder: coder)
    }
    
    private func addContentViews() {

        if self.imageView != nil {
            self.addSubview(self.imageView!)
        }
        
        if self.textField != nil {
            self.addSubview(self.textField!)
        }

        if  let imageView = self.imageView,
            let textView = self.textField {
        
            self.setPositionalContraints(forSubview: imageView, alignment: self.imagePosition)
            self.setPositionalContraints(forSubview: textView, alignment: self.imagePosition.opposite)
                
        } else if let imageView = self.imageView {
            
            self.setCenteredInParentConstraints(forSubview: imageView)

        } else if let textField = self.textField {
            self.setCenteredInParentConstraints(forSubview: textField)
        }
        
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    }
    
    open override var intrinsicContentSize: NSSize {
        var size = CGSize.zero
        
        if let imageView = self.imageView {
            size.width += imageView.intrinsicContentSize.width
            size.height = max(size.height, imageView.intrinsicContentSize.height)
        }
        
        if let textField = self.textField {
            size.width += textField.intrinsicContentSize.width
            size.height = max(size.height, textField.intrinsicContentSize.height)
        }
        
        if self.imageView != nil && self.textField != nil {
            size.width += self.spacing
        }
        
        return size
    }
    
    public func updateForPosition(_ position: SDKView.Position,
                                  inButton button: AbstractButton) {
        
        if  let imageView = self.imageView,
            let textView = self.textField {
        
            imageView.updateForPosition(self.imagePosition, inButton: button)
            textView.updateForPosition(self.imagePosition.opposite, inButton: button)

        } else if let imageView = self.imageView {
            imageView.updateForPosition(.center, inButton: button)

        } else if let textField = self.textField {
            textField.updateForPosition(.left, inButton: button)
        }
    }

    public func wasAdded(toButton button: AbstractButton) {
        self.subviews.forEach {
            if let buttonContent = $0 as? AbstractButtonContentView {
                buttonContent.wasAdded(toButton: button)
            }
        }
    }

    open func updateForDisplay(inButton button: AbstractButton) {
        self.subviews.forEach {
            if let buttonContent = $0 as? AbstractButtonContentView {
                buttonContent.updateForDisplay(inButton: button)
            }
        }
    }
    
    public func updateConstraints(forLayoutInButton button: AbstractButton) {

    }
}
