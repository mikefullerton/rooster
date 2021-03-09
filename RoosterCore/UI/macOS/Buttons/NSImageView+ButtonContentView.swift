//
//  NSImageView+ButtonContentView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Cocoa
import Foundation

extension NSImageView: AbstractButtonContentView {
    public func updateForPosition(_ position: SDKView.Position,
                                  inButton button: AbstractButton) {
        switch position {
        case .left:
            self.imageAlignment = .alignLeft

        case .center:
            self.imageAlignment = .alignCenter

        case .right:
            self.imageAlignment = .alignRight
        }
    }

    public func wasAdded(toButton button: AbstractButton) {
        self.isEditable = false
    }

    public func updateConstraints(forLayoutInButton button: AbstractButton) {
        button.setFillInParentConstraints(forSubview: self)
    }
}
