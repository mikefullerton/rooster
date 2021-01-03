//
//  ViewLayout+Horizontal.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

class HorizontalViewLayout: ViewLayout {
    
    enum Alignment {
        case left
        case right
    }
    
    let hostView: UIView
    let insets:UIEdgeInsets
    let spacing:UIOffset
    let alignment:Alignment

    private(set) var views:[UIView]
    private(set) var didSetConstraints: Bool = false

    init(hostView view: UIView,
         insets: UIEdgeInsets,
         spacing: UIOffset,
         alignment: Alignment = .left) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.alignment = alignment
        self.views = []
    }
    
    private func updateLeadingSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
//        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
//            view.heightAnchor.constraint(equalToConstant: size.height),
//            view.widthAnchor.constraint(equalToConstant: size.width),
        ])
        
        switch(self.alignment) {
        case .left:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left)
            ])
        
        case .right:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right)
            ])
        }
    }
    
    private func updateSubview(_ view: UIView, nextTo: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
//        let size = view.sizeThatFits(self.hostView.frame.size)
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
//            view.heightAnchor.constraint(equalToConstant: size.height),
//            view.widthAnchor.constraint(equalToConstant: size.width),
        ])
        
        switch(self.alignment) {
        case .left:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: self.spacing.horizontal)
            ])
        
        case .right:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: -self.spacing.horizontal)
            ])
        }
    }

    func updateConstraints() {
        if !self.didSetConstraints {
            self.didSetConstraints = true
            
            let subviews = self.views
            
            for (index, view) in subviews.enumerated() {
                if index == 0 {
                    self.updateLeadingSubview(view)
                } else {
                    self.updateSubview(view, nextTo: subviews[ index - 1])
                }
            }
            
        }
    }
    
    func addView(_ view: UIView) {
        self.views.append(view)
        self.hostView.invalidateIntrinsicContentSize()
        self.hostView.setNeedsUpdateConstraints()
    }
    
    var intrinsicContentSize: CGSize {
        return self.horizontalLayoutIntrinsicContentSize
    }
}

