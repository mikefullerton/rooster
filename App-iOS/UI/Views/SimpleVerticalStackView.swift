//
//  SimpleVerticalStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

class SimpleVerticalStackView : UIView {
 
    let insets: UIEdgeInsets
    let spacing: UIOffset
    
    static let defaultInsets = UIEdgeInsets.twenty
    
    init(frame: CGRect,
         insets: UIEdgeInsets = SimpleVerticalStackView.defaultInsets,
         spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10)) {
        
        self.insets = insets
        self.spacing = spacing
        
        super.init(frame: frame)
        
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContainedViews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
        self.layout.setViews(views)
    }

    override var intrinsicContentSize: CGSize {
        return self.layout.intrinsicContentSize
    }

    lazy var layout: VerticalViewLayout = {
        return VerticalViewLayout(hostView: self,
                                  insets:  self.insets,
                                  spacing: self.spacing)
    }()
}

