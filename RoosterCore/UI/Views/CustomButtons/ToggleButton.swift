//
//  ToggleButton.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/23/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class ToggleButton: Button {
    override public var toggled: Bool {
        didSet {
            self.backgroundView.highlighted = self.toggled
        }
    }

    lazy var backgroundView = ButtonBackgroundView()

    override open func didInit() {
        super.didInit()
        self.addSubview(self.backgroundView,
                        positioned: .below,
                        relativeTo: self.contentView,
                        constraints: [ .fill ])
    }
}
