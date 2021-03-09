//
//  ViewLayout+Vertical.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class VerticalViewLayout : ViewLayout {
    public let hostView: SDKView
    public let insets:SDKEdgeInsets
    public let spacing:SDKOffset

//    private(set) var didSetConstraints: Bool = false;
    
    private(set) public var views:[SDKView]
    
    public init(hostView view: SDKView,
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
        
    public func setViews(_ views: [SDKView]) {
        
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
    
    public var intrinsicContentSize: CGSize {
        return self.verticalLayoutIntrinsicContentSize
    }
}


