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

open class ButtonContentsView: AnimateableView, AbstractButtonContentView, Highlightable {
    public private(set) var imageView: NSImageView? = nil {
        didSet { oldValue?.removeFromSuperview() }
    }

    public private(set) var textField: NSTextField? = nil {
        didSet { oldValue?.removeFromSuperview() }
    }

    public var imagePosition: SDKView.Position = .center {
        didSet { self.updateContentViews() }
    }

    public var spacing: CGFloat = 0 {
        didSet { self.updateContentViews() }
    }

    public private(set) var title: String?

    public private(set) var attributedTitle: NSAttributedString?

    public private(set) var image: NSImage?

    public var isHighlighted = false {
        didSet {
            if self.isHighlighted != oldValue {
                self.updateContentViews()
            }
        }
    }

    public var isEnabled = true {
        didSet {
            if self.isEnabled != oldValue {
                self.updateContentViews()
            }
        }
    }

    public func setContent(image: NSImage?, title: String?, attributedTitle: NSAttributedString?) {
        if image != self.image {
            self.image = image
        }

        if let attributedTitle = attributedTitle {
            self.attributedTitle = attributedTitle
        } else if let title = title {
            self.title = title
        }

        self.updateContentViews()
    }

    public init(withImage image: NSImage?,
                title: String?,
                imagePosition: SDKView.Position = .center,
                spacing: CGFloat = 0) {
        super.init(frame: CGRect.zero)
        self.imagePosition = imagePosition
        self.title = title
        self.attributedTitle = nil
        self.image = image
        self.spacing = spacing
        self.updateContentViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func updateAndAddViewsIfNeeded() {
        if let textField = self.textField {
            if let title = self.title {
                textField.stringValue = title
            } else if let attributedTitle = self.attributedTitle {
                textField.attributedStringValue = attributedTitle
            }
        } else if self.title != nil || self.attributedTitle != nil {
            let textField = HighlightableTextField(withButtonTitle: self.title, attributedButtonTitle: self.attributedTitle)
            self.textField = textField
            self.addSubview(textField)
        }

        if let imageView = self.imageView {
            imageView.image = self.image
        } else if let image = self.image {
            let imageView = HighlightableImageView(image: image)
            self.imageView = imageView
            self.addSubview(imageView)
        }
    }

    private func updateContentViews() {
        self.updateAndAddViewsIfNeeded()

        if let imageView = self.imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.removeLocationContraints()

            if self.isEnabled {
                imageView.isEnabled = true
                imageView.isHighlighted = self.isHighlighted
            } else {
                imageView.isEnabled = false
                imageView.isHighlighted = false
            }
        }

        if let textField = self.textField {
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.removeLocationContraints()

            if self.isEnabled {
                textField.isEnabled = true
                textField.isHighlighted = self.isHighlighted
            } else {
                textField.isEnabled = false
                textField.isHighlighted = false
            }
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

    override open var intrinsicContentSize: NSSize {
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

    public func updateConstraints(forLayoutInButton button: AbstractButton) {
    }
}
