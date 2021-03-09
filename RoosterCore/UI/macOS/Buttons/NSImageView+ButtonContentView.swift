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
                                  inButton button: Button) {
        switch position {
        case .left:
            self.imageAlignment = .alignLeft

        case .center:
            self.imageAlignment = .alignCenter

        case .right:
            self.imageAlignment = .alignRight
        }
    }

    public func wasAdded(toButton button: Button) {
        self.isEditable = false
    }

    public func updateConstraints(forLayoutInButton button: Button) {
        self.activateFillInParentConstraints()
    }
}
