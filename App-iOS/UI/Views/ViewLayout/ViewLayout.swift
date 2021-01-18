//
//  ViewLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

protocol ViewLayout {
    var insets:UIEdgeInsets { get }
    var spacing:UIOffset { get }
    var intrinsicContentSize: CGSize { get }
    var hostView: UIView { get }
    var views: [UIView] { get }
}

extension ViewLayout {
    
    var horizontalLayoutIntrinsicContentSize: CGSize {
        var outSize = CGSize.zero

        for view in self.views {
            let size = view.intrinsicContentSize
            
            if size.height > outSize.height {
                outSize.height = size.height
            }
            
            outSize.width += size.width
        }
        
        outSize.height += self.insets.top + self.insets.bottom
        outSize.width += self.insets.left + self.insets.right

//        outSize.height += (self.spacing.vertical * CGFloat(self.views.count - 1))
        outSize.width += (self.spacing.horizontal * CGFloat(self.views.count - 1))

        return outSize
    }
    
    var verticalLayoutIntrinsicContentSize: CGSize {
        
        var outSize = CGSize.zero

        for view in self.views {
            let size = view.intrinsicContentSize
            outSize.height += size.height
            
            if size.width > outSize.width {
                outSize.width = size.width
            }
        }
        
        outSize.height += self.insets.top + self.insets.bottom
        outSize.width += self.insets.left + self.insets.right

        outSize.height += (self.spacing.vertical * CGFloat(self.views.count - 1))
//        outSize.width += (self.spacing.horizontal * CGFloat(self.views.count - 1))

        return outSize
    }
}
