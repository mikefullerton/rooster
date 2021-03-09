//
//  NSTextView+ButtonContentView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

import Cocoa

extension NSTextView: AbstractButtonContentView {
    public func updateForPosition(_ position: SDKView.Position,
                                  inButton button: Button) {
        switch position {
        case .left:
            self.alignment = .left

        case .center:
            self.alignment = .center

        case .right:
            self.alignment = .right
        }
    }

    public func wasAdded(toButton button: Button) {
        self.drawsBackground = false
//        self.isBordered = false
//        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
    }

    public func updateConstraints(forLayoutInButton button: Button) {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
}
