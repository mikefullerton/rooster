//
//  VerticalStackView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit

class VerticalStackView : UIView {
    
    let padding: CGFloat
    
    init(frame: CGRect,
         views: [UIView],
         padding: CGFloat = 0) {
        
        self.padding = padding
        super.init(frame: frame)

        var bottomAnchor = self.topAnchor
        var isFirst = true
        for view in views {
            
            self.addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                view.topAnchor.constraint(equalTo: bottomAnchor, constant: isFirst ? 0 : padding),
            ])
            
            isFirst = false
            
            bottomAnchor = view.bottomAnchor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func sizeThatFits(_ containingSize: CGSize) -> CGSize {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        var size = CGSize(width: containingSize.width, height: 0)
        for view in self.subviews {
            let frame = view.frame
            
            let bottom = frame.origin.y + frame.size.height
            
            if bottom > size.height {
                size.height = bottom
            }
        }
        
        size.height += self.padding
        
        return size
    }

    override open func sizeToFit() {
        let size = self.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
        var frame = self.frame
        frame.size = size
        self.frame = frame
    }

}
