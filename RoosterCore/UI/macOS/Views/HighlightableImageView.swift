//
//  HighlightableImageView.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/11/21.
//

import AppKit
import Foundation

open class HighlightableImageView: SizedImageView {
    private var originalImage: NSImage? {
        didSet {
            self.needsLayout = true
            self.needsDisplay = true
            self.invalidateIntrinsicContentSize()
        }
    }

    public var highlightedColor: NSColor?

    public var disabledColor: NSColor?

    public var normalColor: NSColor?

    public var hightlightedImage: NSImage? {
        self.originalImage?.tint(color: self.highlightedColor ?? Theme(for: self).userChosenHighlightColor)
    }

    public var disabledImage: NSImage? {
        self.originalImage?.tint(color: self.disabledColor ?? Theme(for: self).disabledControlColor)
    }

    public var normalImage: NSImage? {
        if let color = self.normalColor {
            return self.originalImage?.tint(color: color)
        }

        return self.originalImage
    }

    override public init(frame: NSRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public init(image: NSImage) {
        self.originalImage = image
        super.init(image: image)
    }

    private func updateImage() {
        if self.isEnabled {
            self.image = self.isHighlighted ? self.hightlightedImage : self.normalImage
        } else {
            self.image = self.disabledImage
        }

        self.needsLayout = true
        self.invalidateIntrinsicContentSize()
    }

    override open var image: NSImage? {
        didSet {
            assert(self.image != nil, "image is nil")
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            if self.isHighlighted != oldValue {
                self.updateImage()
            }
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if self.isEnabled != oldValue {
                self.updateImage()
            }
        }
    }

    override open var intrinsicContentSize: NSSize {
        self.originalImage?.size ?? super.intrinsicContentSize
    }
}
