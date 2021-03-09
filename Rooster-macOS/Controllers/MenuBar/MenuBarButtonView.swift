//
//  MenuBarButtonView.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import Foundation
import RoosterCore

public protocol MenuBarButtonViewDelegate: AnyObject {
    func menuBarButtonViewContentDidChange(_ menuBarButtonView: MenuBarButtonView)
}

public class MenuBarButtonView: MouseTrackingView, Loggable {
    static let defaultImageSize = CGSize(width: 26, height: 26)

    public weak var delegate: MenuBarButtonViewDelegate?

    let padding: CGFloat = 6

    private let popoverViewController = MenuBarViewController()

    public var contentTintColor: NSColor? {
        didSet { self.contentDidChange() }
    }

    private lazy var titleBarFont = NSFont(name: "monaco", size: 11)!
    private let buttonImage = Assets.whiteRoosterImage!

    private lazy var textField: HighlightableTextField = {
        let view = HighlightableTextField()
        view.font = self.titleBarFont
        view.isEditable = false
        view.textColor = Theme(for: self).labelColor
        view.drawsBackground = false
        view.isBordered = false
        return view
    }()

    private lazy var imageView: HighlightableImageView = {
        let view = HighlightableImageView(image: self.buttonImage)
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.imageView)
        self.imageView.activateConstraint(forPosition: .left)

        self.contentDidChange()

        self.isEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var title: String {
        get {
            self.textField.stringValue
        }
        set {
            self.textField.stringValue = newValue
            self.contentDidChange()
        }
    }

    private func contentDidChange() {
        if !self.textField.stringValue.isEmpty {
            if self.textField.superview == nil {
                self.addSubview(self.textField)
                self.textField.activateConstraint(forPosition: .right)
            }
        } else if self.textField.superview != nil {
            self.textField.removeFromSuperview()
        }

        self.textField.textColor = self.contentTintColor

        if let tintColor = self.contentTintColor {
            self.imageView.image = self.buttonImage.tint(color: tintColor)
        } else {
            self.imageView.image = self.buttonImage
        }

        self.delegate?.menuBarButtonViewContentDidChange(self)
    }

    override public var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width = self.imageView.intrinsicContentSize.width + self.textField.intrinsicContentSize.width + self.padding
        return size
    }

    private var popover: NSPopover?

    override public func mouseDown(with event: NSEvent) {
        let viewController = self.popoverViewController

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = viewController
        popover.contentSize = viewController.preferredContentSize
        popover.show(relativeTo: self.frame, of: self, preferredEdge: .maxY)
        self.popover = popover

        viewController.presentedInPopover = popover

        self.logger.log("hello!")
    }
}
