//
//  AbstractListCellView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

extension AbstractListViewRowController {

    open class RowView : NSView {
        
        open var preferredSize: CGSize? {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }
        
        open override var intrinsicContentSize: CGSize {
            if let preferredSize = self.preferredSize {
                return preferredSize
            }
            
            return super.intrinsicContentSize
        }
    }
}
