//
//  ButtonContentsContainerView.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

#if os(macOS)
import Cocoa
import AppKit
#else
import UIKit
#endif

open class ButtonContentsView: AnimateableView, AbstractButtonContentView {
    private weak var button: Button?

    public private(set) var imageView: NSImageView? {
        didSet { oldValue?.removeFromSuperview() }
    }

    public private(set) var textField: NSTextField? {
        didSet { oldValue?.removeFromSuperview() }
    }

    public var imagePosition: ConstraintDescriptor {
        self.button?.imagePosition ?? .center
    }

    public var textPosition: ConstraintDescriptor {
        self.button?.textPosition ?? .center
    }

    public var spacing: CGFloat {
        self.button?.spacing ?? 0
    }

    public var title: String? {
        self.button?.title ?? ""
    }

    public var attributedTitle: NSAttributedString? {
        self.button?.attributedTitle
    }

    public var image: NSImage? {
        self.button?.image
    }

    public var isHighlighted: Bool {
        if let button = self.button {
            return (button.toggled || button.isHighlighted) && button.isEnabled
        }

        return false
    }

    public var isEnabled: Bool {
        self.button?.isEnabled ?? false
    }

//    public var isHighlighted = false {
//        didSet {
//            if self.isHighlighted != oldValue {
//                self.updateContentViews()
//            }
//        }
//    }
//
//    public var isEnabled = true {
//        didSet {
//            if self.isEnabled != oldValue {
//                self.updateContentViews()
//            }
//        }
//    }

//    public func setContent(withButton button: Button) {
//        self.button = button
//
// //        self.textPosition = textPosition
// //        self.imagePosition = imagePosition
// //
// //        if image != self.image {
// //            self.image = image
// //        }
// //
// //        if let attributedTitle = attributedTitle {
// //            self.attributedTitle = attributedTitle
// //        } else if let title = title {
// //            self.title = title
// //        }
//
//        self.updateContentViews()
//    }

//    public init(withImage image: NSImage?,
//                title: String?,
//                imagePosition: SDKView.Position = .center,
//                spacing: CGFloat = 0) {
//        super.init(frame: CGRect.zero)
//        self.imagePosition = imagePosition
//        self.title = title
//        self.attributedTitle = nil
//        self.image = image
//        self.spacing = spacing
//        self.updateContentViews()
//    }

    public init(withButton button: Button) {
        super.init(frame: CGRect.zero)
        self.button = button
        self.update()
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

    public func update() {
        self.updateAndAddViewsIfNeeded()

        if let imageView = self.imageView {
            if self.isEnabled {
                imageView.isEnabled = true
                imageView.isHighlighted = self.isHighlighted
            } else {
                imageView.isEnabled = false
                imageView.isHighlighted = false
            }
        }

        if let textField = self.textField {
            switch self.textPosition.horizontalAlignment.position {
            case .center:
                textField.alignment = .center

            case .trailing:
                textField.alignment = .right

            case .leading:
                textField.alignment = .left

            case .fill:
                textField.alignment = .left

            case .none:
                break
            }

            if self.isEnabled {
                textField.isEnabled = true
                textField.isHighlighted = self.isHighlighted
            } else {
                textField.isEnabled = false
                textField.isHighlighted = false
            }
        }

        self.resetConstraints()
    }

    private func resetConstraints() {
        if  let imageView = self.imageView, let textField = self.textField, !textField.stringValue.isEmpty {
            imageView.deactivatePositionalContraints()
            textField.deactivatePositionalContraints()

            imageView.activateConstraints(self.imagePosition)
            textField.activateConstraints(self.textPosition)
        } else if let imageView = self.imageView, imageView.image != nil {
            imageView.deactivatePositionalContraints()
            imageView.activateCenteredInSuperviewConstraints()
        } else if let textField = self.textField, !textField.stringValue.isEmpty {
            textField.deactivatePositionalContraints()
            textField.activateCenteredInSuperviewConstraints()
        } else {
//            assertionFailure("no content!")
        }

        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        self.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        self.invalidateIntrinsicContentSize()
    }

    override open var intrinsicContentSize: NSSize {
        var size = CGSize.zero

        if  let imageView = self.imageView,
            let textView = self.textField {
            let imageSize = imageView.intrinsicContentSize
            let textSize = textView.intrinsicContentSize

            if self.imagePosition.verticalAlignment.position == .center && self.textPosition.verticalAlignment.position == .center {
                size.height = max(imageSize.height, textSize.height)
            } else {
                size.height += imageSize.height + textSize.height + self.spacing
            }

            if self.imagePosition.horizontalAlignment.position == .center && self.textPosition.horizontalAlignment.position == .center {
                size.width += imageSize.width + textSize.width + self.spacing
            } else {
                size.width += max(imageSize.width, textSize.width)
            }
        } else if let imageView = self.imageView {
            size.width += imageView.intrinsicContentSize.width
            size.height = max(size.height, imageView.intrinsicContentSize.height)
        } else if let textField = self.textField {
            size.width += textField.intrinsicContentSize.width
            size.height = max(size.height, textField.intrinsicContentSize.height)
        }
        return size
    }

    public func updateForPosition(_ position: ConstraintDescriptor,
                                  inButton button: Button) {
        if  let imageView = self.imageView,
            let textView = self.textField {
            imageView.updateForPosition(self.imagePosition, inButton: button)

            var opposite = self.imagePosition
            opposite.horizontalAlignment.position = opposite.horizontalAlignment.position.opposite

            textView.updateForPosition(opposite, inButton: button)
        } else if let imageView = self.imageView {
            imageView.updateForPosition(.center, inButton: button)
        } else if let textField = self.textField {
            textField.updateForPosition(.leading, inButton: button)
        }
    }

    public func wasAdded(toButton button: Button) {
        self.subviews.forEach {
            if let buttonContent = $0 as? AbstractButtonContentView {
                buttonContent.wasAdded(toButton: button)
            }
        }
    }

    public func updateConstraints(forLayoutInButton button: Button) {
    }
}
