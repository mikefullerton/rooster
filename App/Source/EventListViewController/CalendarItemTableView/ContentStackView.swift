//
//  ContentStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/10/21.
//

import Foundation
import UIKit

class ContentViewStack : UIView {
    
    
    override var intrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        for view in self.subviews {
            let size = view.intrinsicContentSize
            outSize.height += size.height
            
            if size.width > outSize.width {
                outSize.width = size.width
            }
        }
        
//            outSize.height += self.insets.top + self.insets.bottom
//            outSize.width += self.insets.left + self.insets.right
//
//            outSize.height += (self.spacing.vertical * CGFloat(self.views.count - 1))
//        outSize.width += (self.spacing.horizontal * CGFloat(self.views.count - 1))

        return outSize
    }

}
