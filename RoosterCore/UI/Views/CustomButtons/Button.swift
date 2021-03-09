//
//  EmptyButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class Button : AbstractButton, TrackingButtonDelegate, NSMenuDelegate {

    open var representedObject: Any? {
        didSet {
            if let menu = self.popupMenu {
                for item in menu.items {
                    item.representedObject = self.representedObject
                }
            }
        }
    }
    
    public func clearAllMenusStates() {
        self.popupMenu?.items.forEach { $0.state = .off }
    }
    
    public func setMenuState( _ state: NSControl.StateValue, forMenuItemAtIndex index: Int) {
        guard let menuItems = self.popupMenu?.items,
                index < menuItems.count else {
            return
        }
        
        menuItems[index].state = state
    }

    public func setExclusiveMenuState( _ state: NSControl.StateValue, forMenuItemAtIndex index: Int) {
        guard let menuItems = self.popupMenu?.items,
                index < menuItems.count else {
            return
        }

        self.clearAllMenusStates()
        
        menuItems[index].state = state
    }

    fileprivate lazy var button: TrackingButton = {
        let button = TrackingButton()
        button.isTransparent = true
        button.delegate = self
        button.target = self
        button.action = #selector(buttonWasPressed(_:))
        
        button.setContentHuggingPriority(.defaultLow, for: .vertical)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        button.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return button
    }()

    public var popupMenu: NSMenu? {
        didSet {
            if let menu = popupMenu {
                menu.delegate = self
            }
        }
    }
        
    public func menuDidClose(_ menu: NSMenu) {
        self.isHighlighted = false
    }
    
    open func trackingButtonHandleMouseDown(_ button: TrackingButton) {
        
        self.isHighlighted = true

        if  let popupMenu = self.popupMenu,
            let event = NSApplication.shared.currentEvent {
            
            NSMenu.popUpContextMenu(popupMenu, with: event, for: self)
        } else {
        
        }
    }
    
    open func trackingButtonHandleMouseUp(_ button: TrackingButton, mouseIsInside: Bool) {
        self.isHighlighted = false
    }
    
    open func trackingButtonHandleMouseMovedWhilePressed(_ button: TrackingButton, mouseIsInside: Bool) {
        if self.isHighlighted != mouseIsInside {
            self.isHighlighted = mouseIsInside
        }
    }
    
    @objc open func buttonWasPressed(_ trackingButton: TrackingButton) {
        if let target = self.target, let action = self.action {
            _ = target.perform(action, with: self)
        }
    }

    private var buttonContentsContainerView: ButtonContentsView? {
        return self.contentView as? ButtonContentsView
    }
    
    open override var isEnabled: Bool {
        didSet {
            self.button.isEnabled = isEnabled
        }
    }
    
    public fileprivate(set) var isSystemButton: Bool = false
    
    public override init(withContentView view: NSView,
                         target: AnyObject? = nil,
                         action: Selector? = nil) {
        
        super.init(withContentView: view, target: target, action: action)
        self.addButton()
    }
    
    public convenience init(image: NSImage,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        
        let imageView = SizedImageView(image: image)
        self.init(withContentView: ButtonContentsView(withImageView:imageView), target: target, action: action)
        self.image = image
    }
    
    public convenience init(systemSymbolName name: String,
                            accessibilityDescription: String?,
                            symbolConfiguration: NSImage.SymbolConfiguration? = nil,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        
        guard let image = NSImage.image(withSystemSymbolName: name,
                                        accessibilityDescription: accessibilityDescription,
                                        symbolConfiguration: symbolConfiguration) else {
            self.init()
            return
        }
        
        self.init(image: image, target: target, action: action)
    }
    
    public convenience init(imageName: String,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        
        if let image = NSImage(named: imageName) {
            self.init(image: image, target: target, action: action)
        } else {
            self.init()
        }
    }
    
    public convenience init(title: String,
                            image: NSImage,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        
        self.init(title: title,
                  image: image,
                  imagePosition: .left,
                  spacing: 0,
                  target: target,
                  action: action)
    }
    
    public convenience init(title: String,
                            image: NSImage,
                            imagePosition: SDKView.Position,
                            spacing: CGFloat = 0,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
    
        let textField = SDKTextField.buttonTextField(withTitle: title)
        let imageView = SizedImageView(image: image)

        let contentView = ButtonContentsView(withImageView: imageView,
                                             textField: textField,
                                             imagePosition: imagePosition,
                                             spacing: spacing)
        
        self.init(withContentView: contentView)
        
    }

    public convenience init(title: String,
                            target: AnyObject? = nil,
                            action: Selector? = nil) {
        
        let textField = SDKTextField.buttonTextField(withTitle: title)
        self.init(withContentView: ButtonContentsView(withTextField: textField), target: target, action: action)
    }
    
    public convenience init(image: NSImage,
                            menu: NSMenu) {
        
        self.init(image: image)
        
        self.popupMenu = menu
    }

    public convenience init(title: String,
                            menu: NSMenu) {
        
        self.init(title: title)
        
        self.popupMenu = menu
    }

    public convenience init(title: String,
                            image: NSImage,
                            menu: NSMenu) {
        
        self.init(title: title,
                  image: image)
        
        self.popupMenu = menu
    }

    private init() {
        super.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addButton()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addButton()
    }
    
    fileprivate func setButtonToSystemPushIn() {
        self.isSystemButton = true
        self.button.isTransparent = false
        self.button.title = title
        self.button.isBordered = true
        self.button.setButtonType(.momentaryPushIn)
        self.button.bezelStyle = .rounded
    }
    
    public init(systemButtonTitle title: String,
                target: AnyObject? = nil,
                action: Selector? = nil) {
    
        super.init(frame: CGRect.zero)
        self.target = target
        self.action = action
        self.addButton()
        self.setButtonToSystemPushIn()
        self.button.title = title
    }
        
    private func addButton() {
        let view = self.button
        self.addSubview(view)
        self.setFillInParentConstraints(forSubview: view)
    }
    
    public func trackingButton(_ buttton: TrackingButton, didHighlight isHighlighted: Bool) {
        self.isHighlighted = isHighlighted
    }

    // MARK: images
    
    public var imagePosition: NSControl.ImagePosition = .imageLeft
    
    public var imageView: SDKImageView? {
        return self.buttonContentsContainerView?.imageView ?? nil
    }
    
    public var symbolConfiguration: NSImage.SymbolConfiguration? {
        didSet {
            self.updateContentsLayout()
        }
    }
    
    public var image: NSImage? {
        get {
            return self.imageView?.image
        }
        set(image) {
            if image != self.imageView?.image {
                self.imageView?.image = image
                self.updateContentsLayout()
            }
        }
    }
    
    // MARK: text
    
    public var textField: SDKTextField? {
        return self.buttonContentsContainerView?.textField ?? nil
    }
    
    public var title: String {
        get {
            return self.isSystemButton ? self.button.title : self.textField?.stringValue ?? ""
        }
        set(title) {
            if self.isSystemButton {
                self.button.title = title
            } else {
                self.textField?.stringValue = title
            }
            self.updateContentsLayout()
        }
    }
    
    public var keyEquivalent: String {
        get {
            return self.button.keyEquivalent
        }
        set(keyEquivalent) {
            self.button.keyEquivalent = keyEquivalent
        }
    }
    
    public var attributedTitle: NSAttributedString {
        get {
            return self.textField?.attributedStringValue ?? NSAttributedString()
        }
        set(title) {
            self.textField?.attributedStringValue = title
            self.updateContentsLayout()
        }
    }
    
    public var contentTintColor: SDKColor? {
        didSet {
            if self.isSystemButton {
                self.button.contentTintColor = contentTintColor
            }
            
            if let image = self.image,
               let color = self.contentTintColor {
               self.image = image.tint(color: color)
            }
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        if self.isSystemButton {
            return self.button.intrinsicContentSize
        }
        
        let size = super.intrinsicContentSize
        return size
    }
}

extension SDKTextField {
    
    public static func buttonTextField(withTitle title: String) -> SDKTextField {
        let label = SDKTextField()
        label.isEditable = false
        label.stringValue = title
        label.textColor = Theme(for: self).labelColor
        label.drawsBackground = false
        label.isBordered = false

        return label
    }
    
}

open class Switch : Button {
    
    fileprivate func setButtonToSystemSwitch() {
        self.isSystemButton = true
        self.button.isTransparent = false
        self.button.title = title
        self.button.isBordered = false
        self.button.setButtonType(.switch)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setButtonToSystemSwitch()
        self.contentTintColor = Theme(for: self).labelColor
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(title: String,
                            target: AnyObject?,
                            action: Selector?) {

        self.init(frame: CGRect.zero)
        
        self.title = title
        self.target = target
        self.action = action
    }
    
    public var isOn: Bool {
        get {
            return self.button.intValue == 1
        }
        set(isOn) {
            self.button.intValue = isOn ? 1 : 0
        }
    }
}

