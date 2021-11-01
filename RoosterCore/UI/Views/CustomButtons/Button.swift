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

public protocol AbstractButtonContentView {
    func wasAdded(toButton button: Button)
    func updateForPosition(_ position: ConstraintDescriptor,
                           inButton button: Button)
    func updateConstraints(forLayoutInButton button: Button)

    func update()
}

open class Button: AnimateableView, Loggable {
    public typealias Callback = (_ button: Button) -> Void

    public var target: AnyObject?

    public var action: Selector?

    public var preferredContentSize: CGSize? {
        didSet { self.contentsDidChange() }
    }

    public var callback: Callback?

    public private(set) var contentView: NSView?

    public var toggled = false {
        didSet { self.contentsDidChange() }
    }

    public var imagePosition: ConstraintDescriptor {
        didSet { self.contentsDidChange() }
    }

    public var textPosition: ConstraintDescriptor {
        didSet { self.contentsDidChange() }
    }

    public var contentViewPosition: ConstraintDescriptor {
        didSet { self.contentsDidChange() }
    }

    public var isHighlighted: Bool {
        didSet { self.updateContentViewForDisplay() }
    }

    public var contentInsets = SDKEdgeInsets.zero {
        didSet { self.contentsDidChange() }
    }

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

    open var isEnabled: Bool {
        didSet {
            self.updateContentViewForDisplay()
        }
    }

    public var imageView: SDKImageView? {
        self.buttonContentsContainerView?.imageView
    }

    public var symbolConfiguration: NSImage.SymbolConfiguration? {
        didSet {
            self.contentsDidChange()
        }
    }

    public var image: NSImage? {
        didSet {
            self.contentsDidChange()
        }
    }

    public var textField: SDKTextField? {
        self.buttonContentsContainerView?.textField
    }

    public var title: String? = nil {
        didSet {
            self.contentsDidChange()
        }
    }

    public var spacing: CGFloat = 0 {
        didSet {
            self.contentsDidChange()
        }
    }

    public var keyEquivalent: String {
        get { self.mouseEventSource?.keyEquivalent ?? "" }
        set { self.mouseEventSource?.keyEquivalent = newValue }
    }

    public var attributedTitle: NSAttributedString? {
        didSet {
            self.contentsDidChange()
        }
    }

    public var contentTintColor: SDKColor? {
        didSet {
            if oldValue != self.contentTintColor {
                if let textField = self.textField {
                    textField.textColor = self.contentTintColor
                }

                if let image = self.image,
                   let color = self.contentTintColor {
                    self.image = image.tint(color: color)
                } else {
                    self.contentsDidChange()
                }
            }
        }
    }

    public var userInfo: Any?

    public func setTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }
    // MARK: - constructors

    private func setUpContraintPriorities() {
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    public init(title: String?,
                attributedTitle: NSAttributedString?,
                image: NSImage?,
                imagePosition: ConstraintDescriptor,
                textPosition: ConstraintDescriptor,
                spacing: CGFloat,
                target: AnyObject?,
                action: Selector?,
                callback: Callback?) {
        self.title = title
        self.image = image
        self.callback = callback
        self.attributedTitle = attributedTitle
        self.imagePosition = imagePosition
        self.textPosition = textPosition
        self.contentViewPosition = .center
        self.isHighlighted = false
        self.isEnabled = true
        self.target = target
        self.action = action
        self.spacing = spacing
        super.init(frame: CGRect.zero)

        if let contentView = self.createContentView() {
            self.setContentView(contentView)
        }

        self.didInit()
    }

    override public init(frame: CGRect) {
        self.image = nil
        self.title = nil
        self.attributedTitle = nil
        self.imagePosition = .center
        self.textPosition = .center
        self.contentViewPosition = .center
        self.isHighlighted = false
        self.isEnabled = true

        super.init(frame: frame)

        self.didInit()
    }

    public required init?(coder: NSCoder) {
        self.image = nil
        self.title = nil
        self.attributedTitle = nil
        self.imagePosition = .center
        self.contentViewPosition = .center
        self.textPosition = .center
        self.isHighlighted = false
        self.isEnabled = true

        super.init(coder: coder)

        self.didInit()
    }

    open func didInit() {
        self.addMouseEventSource()
        self.setUpContraintPriorities()
    }

    open func handleMouseDown() {
    }

    open func performAction() {
        if let target = self.target, let action = self.action {
            _ = target.perform(action, with: self)
        }

        self.callback?(self)
    }

    open func handleMouseUpInside() {
        self.performAction()
    }

    open func contentsDidChange() {
        if let contentView = self.buttonContentsContainerView {
            contentView.update()
        } else {
            self.updateContentsLayout()
            self.updateContentViewForDisplay()
        }
    }

    public func removeContentView() {
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }

        self.contentView = nil
    }

    open func setContentView(_ view: SDKView) {
        guard view != self.contentView else {
            return
        }

        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }

        self.contentView = view

        if !self.subviews.isEmpty {
            self.addSubview(view, positioned: .below, relativeTo: self.subviews[0])
        } else {
            self.addSubview(view)
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentsDidChange()
    }

    open func updateContentViewConstraints() {
        guard let view = self.contentView else {
            return
        }

        view.deactivatePositionalContraints()
        view.activateConstraints(self.contentViewPosition)

        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        if let view = self.contentView as? AbstractButtonContentView {
            view.wasAdded(toButton: self)
        } else {
            self.logger.error("Unexpected view type in button: \(type(of: view))")
        }

        self.contentsDidChange()
    }

    override open var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        if let size = self.preferredContentSize {
            outSize = size
        } else if let contentView = self.contentView {
            outSize = contentView.intrinsicContentSize
        } else if let mouseEventSource = self.mouseEventSource {
            outSize = mouseEventSource.intrinsicContentSize
        }

        outSize.width += self.contentInsets.left + self.contentInsets.right
        outSize.height += self.contentInsets.top + self.contentInsets.bottom

        return outSize
    }

    public func updateContentViewForDisplay() {
        if let contentView = self.contentView as? AbstractButtonContentView {
            contentView.update()
        }
    }

    public func updateContentsLayout() {
        if let view = self.contentView as? AbstractButtonContentView {
            view.updateForPosition(self.contentViewPosition, inButton: self)
        }

        self.invalidateIntrinsicContentSize()
    }

    open func createContentView() -> SDKView? {
        ButtonContentsView(withButton: self)
    }

    open func createMouseEventSource() -> MouseEventSource {
        let button = TrackingButton()
        button.isTransparent = true
        return button
    }
}

extension Button {
    fileprivate var buttonContentsContainerView: ButtonContentsView? {
        self.contentView as? ButtonContentsView
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
        view.translatesAutoresizingMaskIntoConstraints = false
        self.mouseEventSource = view

        view.activateFillInParentConstraints()
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)

        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
