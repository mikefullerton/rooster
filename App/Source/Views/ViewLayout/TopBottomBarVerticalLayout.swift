//
//  TopBottomBarLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

import UIKit

struct TopBottomBarVerticalLayout: ViewLayout {
    
    let hostView: UIView
    let insets:UIEdgeInsets
    let spacing:UIOffset
    
    var bottomView: UIView? {
        
        if self.hostView.subviews.count == 2 {
            return nil
        }
        
        let bottomView = self.hostView.subviews.last!
        let size = bottomView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            bottomView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            bottomView.bottomAnchor.constraint(equalTo: self.hostView.bottomAnchor, constant: -self.insets.bottom),
            bottomView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return bottomView
    }
    
    var topView: UIView {
        let topView = self.hostView.subviews.first!
        let size = topView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            topView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            topView.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: -self.insets.bottom),
            topView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return topView
    }
    
    private func updateLayout() {
        
        let subviews = self.hostView.subviews
        
        if subviews.count < 2 || subviews.count > 3 {
            return
        }
        
        for view in subviews {
            NSLayoutConstraint.deactivate(view.constraints)
        }
        
        let middleView = self.hostView.subviews[1]
        NSLayoutConstraint.activate([
            middleView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            middleView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            middleView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: self.spacing.vertical),
        ])
        
        if let bottom = self.bottomView {
            NSLayoutConstraint.activate([
                middleView.bottomAnchor.constraint(equalTo: bottom.topAnchor, constant: -self.spacing.vertical),
            ])
        } else {
            NSLayoutConstraint.activate([
                middleView.bottomAnchor.constraint(equalTo: self.hostView.bottomAnchor, constant: -self.insets.bottom),
            ])

        }
    }
    
    func addSubview(_ view: UIView) {
        self.hostView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.updateLayout()
    }
}

