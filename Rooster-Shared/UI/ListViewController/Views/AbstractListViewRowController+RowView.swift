//
//  AbstractListCellView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/24/21.
//

import Foundation
import RoosterCore

extension AbstractListViewRowController {

    class RowView : NSView {
        
        var preferredSize: CGSize? {
            didSet {
                self.invalidateIntrinsicContentSize()
            }
        }
        
        override var intrinsicContentSize: CGSize {
            if let preferredSize = self.preferredSize {
                return preferredSize
            }
            
            return super.intrinsicContentSize
        }
    }
}
