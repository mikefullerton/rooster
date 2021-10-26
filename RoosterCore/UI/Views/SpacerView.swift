//
//  SpacerView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/19/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class SpacerView: SDKView {
    let height: CGFloat

    init(withHeight height: CGFloat) {
        self.height = height

        super.init()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var intrinsicContentSize: NSSize {
        NSSize(width: SDKView.noIntrinsicMetric, height: self.height)
    }
}
