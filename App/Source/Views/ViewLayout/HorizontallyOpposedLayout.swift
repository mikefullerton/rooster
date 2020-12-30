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
    
    private func updateLayout() {
        
        let subviews = self.hostView.subviews
        
        if subviews.count < 2 {
            return
        }
        
        for view in subviews {
            NSLayoutConstraint.deactivate(view.constraints)
        }
        
        var lastView: UIView? = nil
        
        for (index, view) in subviews.reversed().enumerated() {
            let size = view.sizeThatFits(self.hostView.frame.size)

            NSLayoutConstraint.activate([
                view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
                view.heightAnchor.constraint(equalToConstant: size.height),
            ])

            if index == 0 {
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: size.width),
                    view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right)
                ])
            } else if let nextToView = lastView {
                if index == subviews.count - 1 {
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
                        view.trailingAnchor.constraint(equalTo: nextToView.leadingAnchor, constant: -self.spacing.horizontal)
                    ])
                } else {
                    NSLayoutConstraint.activate([
                        view.widthAnchor.constraint(equalToConstant: size.width),
                        view.trailingAnchor.constraint(equalTo: nextToView.leadingAnchor, constant: -self.spacing.horizontal)
                    ])
                }
            }
            
            lastView = view
        }
    }
    
    func addSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.updateLayout()
    }
}

