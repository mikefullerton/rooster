//
//  NSSizedImage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/9/21.
//

import AppKit
import Foundation

open class SizedImageView: NSImageView {
    override public init(frame: NSRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public init(image: NSImage) {
        super.init(frame: CGRect.zero)
        self.image = image
    }

    override open var intrinsicContentSize: NSSize {
        self.image?.size ?? CGSize.zero
    }
}
