//
//  ViewLayout+Vertical.swift
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

class VerticalViewLayout : ViewLayout {
    let hostView: SDKView
    let insets:SDKEdgeInsets
    let spacing:SDKOffset

//    private(set) var didSetConstraints: Bool = false;
    
    private(set) var views:[SDKView]
    
    init(hostView view: SDKView,
         insets: SDKEdgeInsets,
         spacing: SDKOffset) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.views = []
    }

    private func addTopSubview(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            view.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: self.insets.top),
        ])
    }
    
    private func addSubview(_ view: SDKView, belowView: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            view.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            view.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: self.spacing.vertical),
        ])
    }
        
    func setViews(_ views: [SDKView]) {
        
        self.views = views

        for (index, view) in views.enumerated() {
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            if index == 0 {
                self.addTopSubview(view)
            } else {
                self.addSubview(view, belowView: views[ index - 1])
            }
        }
        
        self.hostView.invalidateIntrinsicContentSize()
    }
    
    var intrinsicContentSize: CGSize {
        return self.verticalLayoutIntrinsicContentSize
    }
}


