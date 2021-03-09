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
    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.addBlurView()
        self.addTitleView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var blurView = BlurView()

    func addBlurView() {
        let view = self.blurView
        self.addSubview(view)
        self.setFillInParentConstraints(forSubview: view)
    }

    public lazy var titleView: SDKTextField = {
        let titleView = SDKTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.alignment = .left
        titleView.font = SDKFont.boldSystemFont(ofSize: SDKFont.systemFontSize)
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    public func addTitleView() {
        let titleView = self.titleView

        self.addSubview(titleView)

        titleView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    override open func adornmentWillAppear(withContent content: Any?) {
        if let title = content as? String {
            self.titleView.stringValue = title
        }
    }

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        CGSize(width: -1, height: 30.0)
    }
}
