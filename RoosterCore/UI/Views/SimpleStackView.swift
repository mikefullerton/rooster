//
//  SimpleVerticalStackView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class SimpleStackView: SDKView {
    public enum Direction {
        case vertical
        case horizontal
    }

    private var layout: ViewLayout?

    public init(direction: Direction,
                insets: SDKEdgeInsets = SDKEdgeInsets.zero,
                spacing: SDKOffset = SDKOffset.zero) {
        super.init(frame: CGRect.zero)

        if direction == .vertical {
            self.layout = VerticalViewLayout(hostView: self,
                                             insets: insets,
                                             spacing: spacing)
        } else {
            self.layout = HorizontalViewLayout(hostView: self,
                                               insets: insets,
                                               spacing: spacing,
                                               alignment: .left)
        }

        self.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setContainedViews(_ views: [SDKView]) {
        for view in self.subviews {
            view.removeFromSuperview()
        }

        for view in views {
            self.addSubview(view)
        }
        self.layout!.setViews(views)
    }

    override open var intrinsicContentSize: CGSize {
        self.layout!.intrinsicContentSize
    }
}
