//
//  ImageButton.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/4/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class FancyButton: Button {
    public var animateableContent: AnimatableButtonContentView {
        // swiftlint:disable force_cast
        self.contentView as! AnimatableButtonContentView
        // swiftlint:enable force_cast
    }

    public convenience init() {
        self.init(frame: CGRect.zero)
        self.addContentView()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.addContentView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.addContentView()
    }

    private func addContentView() {
        self.contentViewAlignment = .left
        self.setContentView(AnimatableButtonContentView())
    }
}
