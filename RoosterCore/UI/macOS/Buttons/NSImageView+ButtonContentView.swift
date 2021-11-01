//
//  NSImageView+ButtonContentView.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/20/21.
//

import Cocoa
import Foundation

extension NSImageView: AbstractButtonContentView {
    public func updateForPosition(_ position: ConstraintDescriptor,
                                  inButton button: Button) {
        switch position.horizontalAlignment.position {
        case .leading:
            self.imageAlignment = .alignLeft

        case .center:
            self.imageAlignment = .alignCenter

        case .trailing:
            self.imageAlignment = .alignRight

        case .fill:
            self.imageAlignment = .alignCenter

        case .none:
            break
        }
    }

    public func wasAdded(toButton button: Button) {
        self.isEditable = false
    }

    public func updateConstraints(forLayoutInButton button: Button) {
        self.activateFillInParentConstraints()
    }

    public func update() {
        // TODO: ???
    }
}
