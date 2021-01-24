//
//  SimpleVerticalStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import Cocoa

class SimpleVerticalStackView : NSView {
 
    private var layout: VerticalViewLayout?
    
    init(frame: CGRect,
         insets: NSEdgeInsets,
         spacing: Offset) {
        
        super.init(frame: frame)

        self.layout = VerticalViewLayout(hostView: self,
                                         insets:  insets,
                                         spacing: spacing)

        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContainedViews(_ views: [NSView]) {
        for view in views {
            self.addSubview(view)
        }
        self.layout!.setViews(views)
    }

    override var intrinsicContentSize: CGSize {
        return self.layout!.intrinsicContentSize
    }

    
}

