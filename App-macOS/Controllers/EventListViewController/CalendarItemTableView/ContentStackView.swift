//
//  ContentStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import Cocoa

class ContentViewStack : NSView {
    
    
    override var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        for view in self.subviews {
            let size = view.intrinsicContentSize
            outSize.height += size.height
            
            if size.width > outSize.width {
                outSize.width = size.width
            }
        }
        return outSize
    }

}
