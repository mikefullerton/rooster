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
    var size: CGSize { get }
    var hostView: UIView { get }
    
    func addSubview(_ view: UIView)
}

extension ViewLayout {
    var size: CGSize {
        self.hostView.setNeedsLayout()
        self.hostView.layoutIfNeeded()
        
        var outSize = CGSize.zero

        for view in self.hostView.subviews {
            if view.frame.maxY > outSize.height {
                outSize.height = view.frame.maxY
            }
            
            if view.frame.maxX > outSize.width {
                outSize.width = view.frame.maxX
            }
        }
        
        outSize.height += self.insets.bottom
        outSize.width += self.insets.right
        return outSize
    }
}
