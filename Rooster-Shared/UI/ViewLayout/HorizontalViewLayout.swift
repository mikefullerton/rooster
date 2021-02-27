//
//  ViewLayout+Horizontal.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class HorizontalViewLayout: ViewLayout {
    
    enum Alignment {
        case left
        case right
    }
    
    let hostView: SDKView
    let insets:SDKEdgeInsets
    let spacing:SDKOffset
    let alignment:Alignment

    private(set) var views:[SDKView]

    init(hostView view: SDKView,
         insets: SDKEdgeInsets,
         spacing: SDKOffset,
         alignment: Alignment) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.alignment = alignment
        self.views = []
    }
    
    private func updateLeadingSubview(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
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
    
    private func updateSubview(_ view: SDKView, nextTo: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor),
        ])
        
        switch(self.alignment) {
        case .left:
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: nextTo.trailingAnchor, constant: self.spacing.horizontal)
            ])
        
        case .right:
            NSLayoutConstraint.activate([
                view.trailingAnchor.constraint(equalTo: nextTo.leadingAnchor, constant: -self.spacing.horizontal)
            ])
        }
    }
    
    func setViews(_ views: [SDKView]) {
        
        self.views = views

        for (index, view) in views.enumerated() {
            if index == 0 {
                self.updateLeadingSubview(view)
            } else {
                self.updateSubview(view, nextTo: views[ index - 1])
            }
        }

        self.hostView.invalidateIntrinsicContentSize()
    }
    
    var intrinsicContentSize: CGSize {
        return self.horizontalLayoutIntrinsicContentSize
    }
}

