//
//  TopBottomBarLayout.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class TopBottomBarVerticalLayout: ViewLayout {
    public let hostView: SDKView
    public let insets: SDKEdgeInsets
    public let spacing: SDKOffset

    public private(set) var views: [SDKView]

    public init(hostView view: SDKView,
                insets: SDKEdgeInsets,
                spacing: SDKOffset) {
        self.hostView = view
        self.insets = insets
        self.spacing = spacing
        self.views = []
    }

    private var bottomView: SDKView? {
        if self.hostView.subviews.count == 2 {
            return nil
        }

        let bottomView = self.hostView.subviews.last!
//        let size = bottomView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            bottomView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            bottomView.bottomAnchor.constraint(equalTo: self.hostView.bottomAnchor, constant: -self.insets.bottom)
//            bottomView.heightAnchor.constraint(equalToConstant: size.height)
        ])
        return bottomView
    }

    private var topView: SDKView {
        let topView = self.hostView.subviews.first!
//        let size = topView.sizeThatFits(self.hostView.frame.size)
        NSLayoutConstraint.activate([
            topView.leadingAnchor.constraint(equalTo: self.hostView.leadingAnchor, constant: self.insets.left),
            topView.trailingAnchor.constraint(equalTo: self.hostView.trailingAnchor, constant: -self.insets.right),
            topView.topAnchor.constraint(equalTo: self.hostView.topAnchor, constant: -self.insets.bottom)
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
            middleView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: self.spacing.vertical)
        ])

        if let bottom = self.bottomView {
            NSLayoutConstraint.activate([
                middleView.bottomAnchor.constraint(equalTo: bottom.topAnchor, constant: -self.spacing.vertical)
            ])
        } else {
            NSLayoutConstraint.activate([
                middleView.bottomAnchor.constraint(equalTo: self.hostView.bottomAnchor, constant: -self.insets.bottom)
            ])
        }
    }

    public func setViews(_ views: [SDKView]) {
        self.views = views
        self.updateLayout()
//        self.hostView.setNeedsUpdateConstraints()
    }

    public var intrinsicContentSize: CGSize {
        self.verticalLayoutIntrinsicContentSize
    }
}
