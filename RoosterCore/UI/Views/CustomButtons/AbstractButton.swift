//
//  AbstractButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public protocol AbstractButtonContentView {
    func wasAdded(toButton button: AbstractButton)
    func updateForPosition(_ position: SDKView.Position,
                           inButton button: AbstractButton)
    func updateConstraints(forLayoutInButton button: AbstractButton)
}

open class AbstractButton: AnimateableView, Loggable {
    public var target: AnyObject?

    public var action: Selector?

    public var preferredContentSize: CGSize?

    open var isEnabled = true {
        didSet {
            self.updateContentViewForDisplay()
        }
    }

    public private(set) var contentView: NSView?

    public var contentViewAlignment: Position = .center {
        didSet {
            self.updateContentViewForDisplay()
        }
    }

    public var isHighlighted = false {
        didSet {
            self.updateContentViewForDisplay()
        }
    }

    public var contentInsets = SDKEdgeInsets.zero

    public init(withContentView view: NSView,
                target: AnyObject?,
                action: Selector? = nil) {
        self.target = target
        self.action = action

        super.init(frame: CGRect.zero)

        self.setUp()
        self.setContentView(view)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setUp()
    }

    private func setUp() {
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        self.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
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

        self.setPositionalContraints(forSubview: view, alignment: self.contentViewAlignment )

        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        if let view = self.contentView as? AbstractButtonContentView {
            view.wasAdded(toButton: self)
        } else {
            self.logger.error("Unexpected view type in button: \(type(of: view))")
        }

        self.updateContentsLayout()
    }

    public func updateContentsLayout() {
        if let view = self.contentView as? AbstractButtonContentView {
            view.updateForPosition(self.contentViewAlignment, inButton: self)
        }

        self.invalidateIntrinsicContentSize()

        self.updateContentViewForDisplay()
    }

    public func updateContentViewForDisplay() {
        if var highlightable = self.contentView as? Highlightable {
            highlightable.isEnabled = self.isEnabled
            highlightable.isHighlighted = self.isHighlighted && self.isEnabled
        }
    }

    public func setTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }

    override open var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        if let contentView = self.contentView {
            outSize = self.preferredContentSize ?? contentView.intrinsicContentSize
        }

        outSize.width += self.contentInsets.left + self.contentInsets.right
        outSize.height += self.contentInsets.top + self.contentInsets.bottom

        return outSize
    }
}
