//
//  SectionHeaderView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/23/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class SectionHeaderView: ListViewAdornmentView {
    var contentView: SDKView?

    lazy var blurView = BlurView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.addBlurView()
        self.contentView = nil
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addBlurView() {
        let view = self.blurView
        self.addSubview(view)
        view.activateFillInParentConstraints()
    }

    open func set(contentView newContentView: SDKView?) {
        if let contentView = self.contentView {
            contentView.removeFromSuperview()
        }

        self.contentView = newContentView

        if let contentView = self.contentView {
            self.addSubview(contentView)

            contentView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        }
    }

    override open func adornmentWillAppear(withContent content: Any?) {
        if let title = content as? String,
           let contentView = self.contentView as? SDKTextField {
            contentView .stringValue = title
        }
    }

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 30.0)
    }
}
