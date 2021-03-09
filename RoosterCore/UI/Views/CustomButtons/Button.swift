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

open class Button: AbstractButton {
    internal var mouseEventSource: MouseEventSource? {
        didSet {
            if oldValue !== self.mouseEventSource {
                oldValue?.mouseEventReceiver = nil

                if let mouseEventSource = self.mouseEventSource {
                    mouseEventSource.mouseEventReceiver = self
                }
            }
        }
    }

    private var buttonContentsContainerView: ButtonContentsView? {
        self.contentView as? ButtonContentsView
    }

    override open var isEnabled: Bool {
        didSet {
            self.mouseEventSource?.isEnabled = isEnabled
        }
    }

    public var imagePosition: NSControl.ImagePosition = .imageLeft

    public var imageView: SDKImageView? {
        self.buttonContentsContainerView?.imageView
    }

    public var symbolConfiguration: NSImage.SymbolConfiguration? {
        didSet {
            self.contentsDidChange()
            self.updateContentsLayout()
        }
    }

    public var image: NSImage? {
        didSet {
            self.contentsDidChange()
            self.updateContentsLayout()
        }
    }

    public var textField: SDKTextField? {
        self.buttonContentsContainerView?.textField
    }

    public var title: String? = nil {
        didSet {
            self.contentsDidChange()
            self.updateContentsLayout()
        }
    }

    public var keyEquivalent: String {
        get { self.mouseEventSource?.keyEquivalent ?? "" }
        set { self.mouseEventSource?.keyEquivalent = newValue }
    }

    public var attributedTitle: NSAttributedString? {
        didSet {
            self.contentsDidChange()
            self.updateContentsLayout()
        }
    }

    public var contentTintColor: SDKColor? {
        didSet {
            if oldValue != self.contentTintColor {
                if let image = self.image,
                   let color = self.contentTintColor {
                   self.image = image.tint(color: color)
                } else {
                    self.contentsDidChange()
                }
            }
        }
    }

    // MARK: - constructors

    override public init(withContentView view: NSView,
                         target: AnyObject? = nil,
                         action: Selector? = nil) {
        super.init(withContentView: view, target: target, action: action)
        self.addMouseEventSource()
    }

    internal class func createContentView(withImage image: NSImage?,
                                          title: String?,
                                          imagePosition: SDKView.Position = .center,
                                          spacing: CGFloat = 0) -> SDKView {
        ButtonContentsView(withImage: image, title: title, imagePosition: imagePosition, spacing: spacing)
    }

    public init(image: NSImage,
                target: AnyObject? = nil,
                action: Selector? = nil) {
        self.image = image
        self.title = nil
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: image, title: title)
        super.init(withContentView: contentView, target: target, action: action)
        self.addMouseEventSource()
    }

    public init?(systemSymbolName name: String,
                 accessibilityDescription: String?,
                 symbolConfiguration: NSImage.SymbolConfiguration? = nil,
                 target: AnyObject? = nil,
                 action: Selector? = nil) {
        guard let image = NSImage.image(withSystemSymbolName: name,
                                        accessibilityDescription: accessibilityDescription,
                                        symbolConfiguration: symbolConfiguration) else {
            return nil
        }

        self.image = image
        self.title = nil
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: image, title: title)
        super.init(withContentView: contentView, target: target, action: action)
        self.addMouseEventSource()
    }

    public init?(imageName: String,
                 target: AnyObject? = nil,
                 action: Selector? = nil) {
        guard let image = NSImage(named: imageName) else {
            return nil
        }

        self.image = image
        self.title = nil
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: image, title: title)
        super.init(withContentView: contentView, target: target, action: action)
        self.addMouseEventSource()
    }

    public init(title: String,
                image: NSImage,
                imagePosition: SDKView.Position = .center,
                spacing: CGFloat = 0,
                target: AnyObject? = nil,
                action: Selector? = nil) {
        self.title = title
        self.image = image
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: image,
                                                 title: title,
                                                 imagePosition: imagePosition,
                                                 spacing: spacing)

        super.init(withContentView: contentView, target: target, action: action)
        self.addMouseEventSource()
    }

    public init(title: String,
                target: AnyObject? = nil,
                action: Selector? = nil) {
        self.image = nil
        self.title = title
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: nil, title: title)

        super.init(withContentView: contentView, target: target, action: action)
        self.addMouseEventSource()
    }

    private init() {
        self.image = nil
        self.title = nil
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: nil, title: nil)
        super.init(withContentView: contentView, target: nil, action: nil)
        self.addMouseEventSource()
    }

    override public init(frame: CGRect) {
        self.image = nil
        self.title = nil
        self.attributedTitle = nil

        let contentView = Self.createContentView(withImage: nil, title: nil)
        super.init(withContentView: contentView, target: nil, action: nil)
        self.addMouseEventSource()
    }

    public required init?(coder: NSCoder) {
        self.image = nil
        self.title = nil
        self.attributedTitle = nil

        super.init(coder: coder)
        let contentView = Self.createContentView(withImage: nil, title: nil)
        self.setContentView(contentView)
        self.addMouseEventSource()
    }

    open func handleMouseDown() {
    }

    open func handleMouseUpInside() {
        if let target = self.target, let action = self.action {
            _ = target.perform(action, with: self)
        }
    }

    open func createMouseEventSource() -> MouseEventSource {
        let button = TrackingButton()
        button.isTransparent = true
        return button
    }

    func contentsDidChange() {
        if let contentView = self.buttonContentsContainerView {
            contentView.setContent(image: self.image, title: self.title, attributedTitle: self.attributedTitle)
        }
    }

    override public func updateContentsLayout() {
        super.updateContentsLayout()
    }
}

extension Button: MouseEventRecieving {
    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseMoved mouseEvent: MouseEvent) {
        self.isHighlighted = mouseEvent.isMouseDown && mouseEvent.isMouseInside
    }

    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseEntered mouseEvent: MouseEvent) {
        self.isHighlighted = mouseEvent.isMouseDown
    }

    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseExited mouseEvent: MouseEvent) {
        self.isHighlighted = false
    }

    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseDown mouseEvent: MouseEvent) {
        self.isHighlighted = true
        self.handleMouseDown()
    }

    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseUp mouseEvent: MouseEvent) {
        self.isHighlighted = false
        if mouseEvent.isMouseInside {
            self.handleMouseUpInside()
        }
    }

    public func mouseEventSource(_ mouseEventSource: MouseEventSource,
                                 mouseDragged mouseEvent: MouseEvent) {
        self.isHighlighted = mouseEvent.isMouseDown && mouseEvent.isMouseInside
    }
}

extension Button {
    fileprivate func addMouseEventSource() {
        let view = self.createMouseEventSource()
        self.addSubview(view)
        self.setFillInParentConstraints(forSubview: view)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)

        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.mouseEventSource = view
    }
}
