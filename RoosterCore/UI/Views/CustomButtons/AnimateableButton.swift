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

open class AnimateableButton: Button {
    private let animateableContentView = AnimatableButtonContentView()

    public var contentViews: [SDKView] {
        get { self.animateableContentView.contentViews }
        set {
            self.animateableContentView.contentViews = newValue
            if !newValue.isEmpty && self.contentView == nil {
                self.setContentView(self.animateableContentView)
            }
        }
    }

    public var viewIndex: Int {
        get { self.animateableContentView.viewIndex }
        set { self.animateableContentView.viewIndex = newValue }
    }

    public func incrementViewIndex() {
        self.animateableContentView.setNextAnimatableView()
    }

    public var viewCount: Int {
        self.animateableContentView.viewCount
    }

    public var maxViewIndex: Int {
        self.animateableContentView.maxViewIndex
    }
}
