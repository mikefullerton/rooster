//
//  HorizontallyOpposedLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import Cocoa

class HorizontallyOpposedLayout: ViewLayout {
    
    
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

    private func setSubviewConstraints() {
        var lastView: NSView? = nil
        
        for (index, view) in self.views.reversed().enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
            ])

            if index == 0 {
                NSLayoutConstraint.activate([
                    view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right)
                ])
            } else if let nextToView = lastView {
                if index == self.views.count - 1 {
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
                        view.trailingAnchor.constraint(equalTo: nextToView.leadingAnchor, constant: -self.spacing.horizontal)
                    ])
                } else {
                    NSLayoutConstraint.activate([
                        view.trailingAnchor.constraint(equalTo: nextToView.leadingAnchor, constant: -self.spacing.horizontal)
                    ])
                }
            }
            
            lastView = view
        }
    }
    
    func setViews(_ views: [NSView]) {
        self.views = views
        self.setSubviewConstraints()
//        self.hostView.setNeedsUpdateConstraints()
    }

    var intrinsicContentSize: CGSize {
        return self.horizontalLayoutIntrinsicContentSize
    }
}

