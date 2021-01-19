//
//  TopBottomBarLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

import Cocoa

class TopBottomBarVerticalLayout: ViewLayout {
    
    let hostView: NSView
    let insets:NSEdgeInsets
    let spacing:Offset
    
    private(set) var views: [NSView]
    
    init(hostView view: NSView,
         insets: NSEdgeInsets,
         spacing: Offset) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.views = []
    }

    private var bottomView: NSView? {
        
        if self.hostView.subviews.count == 2 {
            return nil
        }
        
        let bottomView = self.hostView.subviews.last!
//        let size = bottomView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            bottomView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            bottomView.bottomAnchor.constraint(equalTo: self.hostView.bottomAnchor, constant: -self.insets.bottom),
//            bottomView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return bottomView
    }
    
    private var topView: NSView {
        let topView = self.hostView.subviews.first!
//        let size = topView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            topView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            topView.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: -self.insets.bottom),
//            topView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return topView
    }
    
    private func updateLayout() {
        
        let subviews = self.views
        
        if subviews.count < 2 || subviews.count > 3 {
            return
        }
        
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            
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
    
    func setViews(_ views: [NSView]) {
        self.views = views
        self.updateLayout()
        self.hostView.setNeedsUpdateConstraints()
    }

    var intrinsicContentSize: CGSize {
        return self.verticalLayoutIntrinsicContentSize
    }

    
    
}

