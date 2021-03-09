//
//  NSTextView+ButtonContentView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Foundation

import Cocoa

extension NSTextView : AbstractButtonContentView {
    
    public func updateForPosition(_ position: SDKView.Position,
                           inButton button: AbstractButton) {
        switch(position) {
            case .left:
                self.alignment = .left
                
            case .center:
                self.alignment = .center
                
            case .right:
                self.alignment = .right
        }
    }

    public func wasAdded(toButton button: AbstractButton) {
        

        self.drawsBackground = false
//        self.isBordered = false
//        self.isBezeled = false
        self.isEditable = false
        self.isSelectable = false
    }

    public func updateForDisplay(inButton button: AbstractButton) {
        if !button.isEnabled {
            self.alphaValue = 0.4
        } else if button.isHighlighted {
            self.alphaValue = 0.6
        } else {
            self.alphaValue = 1.0
        }
    }

    public func updateConstraints(forLayoutInButton button: AbstractButton) {
        NSLayoutConstraint.activate([
            self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: button.contentInsets.left),
            self.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -button.contentInsets.right),
            self.heightAnchor.constraint(equalToConstant: self.intrinsicContentSize.height),
            self.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
}


