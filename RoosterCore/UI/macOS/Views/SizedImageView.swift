//
//  NSSizedImage.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 3/9/21.
//

import Foundation
import AppKit

open class SizedImageView : NSImageView {
    
    open override var intrinsicContentSize: NSSize {
        return self.image?.size ?? CGSize.zero
    }
}
