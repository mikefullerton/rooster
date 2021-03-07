//
//  AbstractListCellView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
import RoosterCore

extension AbstractListViewRowController {

    open class RowView : NSView {
        
        public var preferredSize: CGSize? {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }
        
        public override var intrinsicContentSize: CGSize {
            if let preferredSize = self.preferredSize {
                return preferredSize
            }
            
            return super.intrinsicContentSize
        }
    }
}
