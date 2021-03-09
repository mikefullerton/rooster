//
//  ContentAwareView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/6/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class ContentAwareView : SDKView {

    open override var intrinsicContentSize: CGSize {
        var maxSize = CGSize.zero
        
        for subview in self.subviews {
            let size = subview.intrinsicContentSize
            
            if size.width > maxSize.width {
                maxSize.width = size.width
            }
            
            if size.height > maxSize.height {
                maxSize.height = size.height
            }
        }
    
        let outSize = CGSize(width: maxSize.width,
                             height: maxSize.height)
        
        return outSize
    }
   
}
