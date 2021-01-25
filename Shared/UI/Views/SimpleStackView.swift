//
//  SimpleVerticalStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class SimpleStackView : SDKView {
 
    enum Direction {
        case vertical
        case horizontal
    }
    
    private var layout: ViewLayout?
    
    init(frame: CGRect,
         direction: Direction,
         insets: SDKEdgeInsets,
         spacing: SDKOffset) {
        
        super.init(frame: frame)

        if direction == .vertical {
            self.layout = VerticalViewLayout(hostView: self,
                                             insets:  insets,
                                             spacing: spacing)
        } else {
            self.layout = HorizontalViewLayout(hostView: self,
                                               insets:  insets,
                                               spacing: spacing,
                                               alignment: .left)
        }

        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContainedViews(_ views: [SDKView]) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for view in views {
            self.addSubview(view)
        }
        self.layout!.setViews(views)
    }

    override var intrinsicContentSize: CGSize {
        return self.layout!.intrinsicContentSize
    }

    
}

