//
//  NSTextField+ButtonContentView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Cocoa
import Foundation

extension NSTextField: AbstractButtonContentView {
    public func updateForPosition(_ position: ConstraintDescriptor,
                                  inButton button: Button) {
//        switch(button.contentViewPosition) {
//            case .left:
//                self.imageAlignment = .alignLeft
//
//            case .center:
//                self.imageAlignment = .alignCenter
//
//            case .right:
//                self.imageAlignment = .alignRight
//        }

    }

    public func wasAdded(toButton button: Button) {
        self.drawsBackground = false
        self.isBordered = false
        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
    }

//    public func updateForDisplay(inButton button: Button) {
//        if !button.isEnabled {
//            self.alphaValue = 0.4
//        } else if button.isHighlighted {
//            self.alphaValue = 0.6
//        } else {
//            self.alphaValue = 1.0
//        }
//    }

    public func updateConstraints(forLayoutInButton button: Button) {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    public func update() {
        // TODO: ???
    }
}
