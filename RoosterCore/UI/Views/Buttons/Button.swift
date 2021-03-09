//
//  EmptyButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

import AppKit

public protocol ButtonContentView {
    func updateSettings(inButton button: Button)
    func wasAdded(toButton button: Button)
    var preferredButtonSize: CGSize { get }
}

open class Button : AnimateableView, Loggable, TrackingButtonDelegate {

    private lazy var button: TrackingButton = {
        let button = TrackingButton()
        button.isTransparent = true
        button.delegate = self
        return button
    }()
    
    public var target: AnyObject? {
        get {
            return self.button.target
        }
        set(target) {
            self.button.target = target
        }
    }
    
    public var action: Selector? {
        get {
            return self.button.action
        }
        set(action) {
            self.button.action = action
        }
    }
    
    public var isEnabled: Bool = true {
        didSet {
            self.button.isEnabled = self.isEnabled
            self.updateContents()
        }
    }
    
    private(set) var contentView: NSView?
    
    public var contentViewAlignment: SubviewAlignment = .center {
        didSet {
            self.updateContents()
        }
    }
    
    public var isHighlighted: Bool = false {
        didSet {
            self.updateContents()
        }
    }
    
    public var contentInsets: SDKEdgeInsets = SDKEdgeInsets.zero
    
    public init(withContentView view: NSView) {
        super.init(frame: CGRect.zero)
        
        self.setContentView(view)
        self.addButton()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addButton()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addButton()
    }
    
    public func setContentView(_ view: SDKView) {
        guard view != self.contentView else {
            return
        }
        
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }
        
        self.contentView = view
        self.addSubview(view, positioned: .below, relativeTo: self.button)
        
        self.setPositionalContraints(forSubview: view, alignment: self.contentViewAlignment )
        
        view.translatesAutoresizingMaskIntoConstraints = false

        
        if let view = self.contentView as? ButtonContentView {
            view.wasAdded(toButton: self)
        } else {
            self.logger.error("Unexpected view type in button: \(type(of:view))")
        }

        self.invalidateIntrinsicContentSize()

        self.updateContents()
    }
    
    public func updateContents() {
        if let view = self.contentView as? ButtonContentView {
            view.updateSettings(inButton: self)
        }
    }
    
    public func setTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
    
    open override var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero
        
        if let contentView = self.contentView {
            if let view = self.contentView as? ButtonContentView {
                outSize = view.preferredButtonSize
            } else {
                outSize = contentView.intrinsicContentSize
            }
        }
            
        outSize.width += self.contentInsets.left + self.contentInsets.right
        outSize.height += self.contentInsets.top + self.contentInsets.bottom
        
        return outSize
    }
    
    private func addButton() {
        let view = self.button
        self.addSubview(view)
        
        self.setFillInParentConstraints(forSubview: view)
//        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        view.setContentHuggingPriority(.defaultLow, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    public func trackingButton(_ buttton: TrackingButton, didHighlight isHighlighted: Bool) {
        self.isHighlighted = isHighlighted
    }

}

extension NSImageView : ButtonContentView {

    public func updateSettings(inButton button: Button) {
        switch(button.contentViewAlignment) {
            case .left:
                self.imageAlignment = .alignLeft
                
            case .center:
                self.imageAlignment = .alignCenter
                
            case .right:
                self.imageAlignment = .alignRight
        }
    
        if !button.isEnabled {
            self.alphaValue = 0.4
        } else if button.isHighlighted {
            self.alphaValue = 0.6
        } else {
            self.alphaValue = 1.0
        }
    }
    
    public var preferredButtonSize: CGSize {
        if let size = self.image?.size {
            return size
        }
        
        return self.intrinsicContentSize
    }
    
    public func wasAdded(toButton button: Button) {
        
        button.setFillInParentConstraints(forSubview: self)
        
//        NSLayoutConstraint.activate([
//            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
//            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
//            self.heightAnchor.constraint(equalToConstant: self.preferredButtonSize.height),
//            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
//        ])

        
//        self.drawsBackground = false
//        self.isBordered = false
//        self.isBezeled = false
//        self.isEditable = false
//        self.isSelectable = false
    }

}

extension NSTextView : ButtonContentView {
    
    public func updateSettings(inButton button: Button) {
//        switch(button.contentViewAlignment) {
//            case .left:
//                self.imageAlignment = .alignLeft
//
//            case .center:
//                self.imageAlignment = .alignCenter
//
//            case .right:
//                self.imageAlignment = .alignRight
//        }
        switch(button.contentViewAlignment) {
            case .left:
                self.alignment = .left
                
            case .center:
                self.alignment = .center
                
            case .right:
                self.alignment = .right
        }

        
        if !button.isEnabled {
            self.alphaValue = 1.0
        } else if button.isHighlighted {
            self.alphaValue = 0.6
        } else {
            self.alphaValue = 1.0
        }
    }

    public var preferredButtonSize: CGSize {
        return self.intrinsicContentSize
    }

    public func wasAdded(toButton button: Button) {
        
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])

//        self.drawsBackground = false
//        self.isBordered = false
//        self.isBezeled = false
//        self.isEditable = false
//        self.isSelectable = false
    }

}

extension NSTextField : ButtonContentView {
    
    public func updateSettings(inButton button: Button) {
//        switch(button.contentViewAlignment) {
//            case .left:
//                self.imageAlignment = .alignLeft
//
//            case .center:
//                self.imageAlignment = .alignCenter
//
//            case .right:
//                self.imageAlignment = .alignRight
//        }
    
        if !button.isEnabled {
            self.alphaValue = 1.0
        } else if button.isHighlighted {
            self.alphaValue = 0.6
        } else {
            self.alphaValue = 1.0
        }
    }

    public var preferredButtonSize: CGSize {
        return self.intrinsicContentSize
    }

    public func wasAdded(toButton button: Button) {
        self.drawsBackground = false
        self.isBordered = false
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
        
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])

    }
}
