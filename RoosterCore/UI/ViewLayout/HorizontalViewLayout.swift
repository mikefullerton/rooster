//
//  ViewLayout+Horizontal.swift
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

public  class HorizontalViewLayout: ViewLayout {
    public enum Alignment {
        case left
        case right
    }

    public let hostView: SDKView
    public let insets: SDKEdgeInsets
    public let spacing: SDKOffset
    public let alignment: Alignment

    public private(set) var views: [SDKView]

    public init(hostView view: SDKView,
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
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor)
//            view.widthAnchor.constraint(equalToConstant: view.fittingSize.width),
//            view.heightAnchor.constraint(equalToConstant: view.fittingSize.height),

        ])

        switch self.alignment {
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
            view.centerYAnchor.constraint(equalTo: self.hostView.centerYAnchor)
//            view.widthAnchor.constraint(equalToConstant: view.fittingSize.width),
//            view.heightAnchor.constraint(equalToConstant: view.fittingSize.height),
        ])

        switch self.alignment {
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

    public func setViews(_ views: [SDKView]) {
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

    public var intrinsicContentSize: CGSize {
        self.horizontalLayoutIntrinsicContentSize
    }
}
