//
//  TopBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/30/20.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class TopBar: BlurView {
    open var preferredHeight: CGFloat {
        40.0
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
//        self.setContentHuggingPriority(., for: .vertical)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.backgroundColor = SDKColor.clear
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.isBordered = false
        titleView.drawsBackground = false
        titleView.isEditable = false
        titleView.alignment = .center
        return titleView
    }()

    public func addTitleView(withText text: String) {
        let titleView = self.titleView
        titleView.stringValue = text

        self.addSubview(titleView)

        titleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    public func addToView(_ view: SDKView) {
        view.addSubview(self)

        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: self.preferredHeight),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override open var intrinsicContentSize: CGSize {
        CGSize(width: SDKView.noIntrinsicMetric, height: self.preferredHeight)
    }
}
