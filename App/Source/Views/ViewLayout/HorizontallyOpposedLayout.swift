//
//  HorizontallyOpposedLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

struct HorizontallyOpposedLayout: ViewLayout {
    
    let hostView: UIView
    let insets:UIEdgeInsets
    let spacing:UIOffset
    
    func addSubview(_ view: UIView) {
        
        let startViewCount = self.hostView.subviews.count
        
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            view.heightAnchor.constraint(equalToConstant: size.height),
            view.widthAnchor.constraint(equalToConstant: size.width),
        ])
        
        if startViewCount == 0 {
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left)
            ])
        } else if (startViewCount == 1) {
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right)
            ])
        } else {
            let lastView = self.hostView.subviews[self.hostView.subviews.count - 2]

            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: lastView.leadingAnchor, constant: -self.spacing.horizontal)
            ])
        }
    }
}

