//
//  HighlightableImageView.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/11/21.
//

import AppKit
import Foundation

public class HighlightableImageView: SizedImageView {
    private var originalImage: NSImage?

    public var hightlightedImage: NSImage? {
        self.originalImage?.tint(color: Theme(for: self).userChosenHighlightColor)
    }

    public var disabledImage: NSImage? {
        self.originalImage?.tint(color: Theme(for: self).disabledControlColor)
    }

    override public init(frame: NSRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public init(image: NSImage) {
        super.init(image: image)
        self.originalImage = image
    }

    private func updateImage() {
        if self.isEnabled {
            self.image = self.isHighlighted ? self.hightlightedImage : self.originalImage
        } else {
            self.image = self.disabledImage
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
}
