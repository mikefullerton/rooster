//
//  HorizontallyOpposedLayout.swift
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

public class HorizontallyOpposedLayout: ViewLayout {
    public let hostView: SDKView
    public let insets:SDKEdgeInsets
    public let spacing:SDKOffset
    
    public private(set) var views: [SDKView]
    
    public init(hostView view: SDKView,
                insets: SDKEdgeInsets,
                spacing: SDKOffset) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.views = []
    }

    private func setSubviewConstraints() {
        var lastView: SDKView?
        
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
    
    public func setViews(_ views: [SDKView]) {
        self.views = views
        self.setSubviewConstraints()
//        self.hostView.setNeedsUpdateConstraints()
    }

    public var intrinsicContentSize: CGSize {
        return self.horizontalLayoutIntrinsicContentSize
    }
}

