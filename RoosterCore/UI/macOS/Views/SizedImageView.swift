//
//  NSSizedImage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/9/21.
//

import Foundation
import AppKit

open class SizedImageView : NSImageView {
       
    public override init(frame: NSRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init(image: NSImage) {
        self.init(frame: CGRect.zero)
        self.image = image
    }
    
    open override var intrinsicContentSize: NSSize {
        return self.image?.size ?? CGSize.zero
    }
}
