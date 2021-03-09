//
//  TipView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/27/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public struct Tip {
    public let image: SDKImage?
    public let imageTintColor: SDKColor?
    public let title: String
    public let action: (() -> Void)?

    public init(withImage image: SDKImage?,
                imageTintColor: SDKColor?,
                title: String,
                action: ((() -> Void)?)) {
        self.image = image
        self.imageTintColor = imageTintColor
        self.title = title
        self.action = action
    }
}

open class TipView: SDKView {
    public let tip: Tip

    public init(frame: CGRect,
                tip: Tip) {
        self.tip = tip
        super.init(frame: frame)

        self.addSubview(self.tipImage)
        self.addSubview(self.textField)

        self.layout.setViews([
            self.tipImage,
            self.textField
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public lazy var textField: SDKTextField = {
        let titleView = SDKTextField()
        titleView.stringValue = self.tip.title
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false

        return titleView
    }()

    public let imageSize: CGFloat = 14.0

    public lazy var tipImage: SDKImageView = {
        guard let image = self.tip.image else {
            return SDKImageView()
        }

        let view = SDKImageView(image: image)
        if self.tip.imageTintColor != nil {
            view.contentTintColor = self.tip.imageTintColor! // SDKColor.systemBlue
        }
        return view
    }()

    override open var intrinsicContentSize: CGSize {
        CGSize(width: SDKView.noIntrinsicMetric, height: self.layout.intrinsicContentSize.height)
    }

    open lazy var layout: HorizontalViewLayout = {
        HorizontalViewLayout(hostView: self,
                             insets: SDKEdgeInsets(top: 2, left: 20, bottom: 10, right: 0),
                             spacing: SDKOffset(horizontal: 6, vertical: 0),
                             alignment: .left)
    }()
}
