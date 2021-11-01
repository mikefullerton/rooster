//
//  DividerView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class DividerView: ListViewAdornmentView {
    public let height: CGFloat

    public init(withHeight height: CGFloat) {
        self.height = height

        super.init(frame: CGRect.zero)

        let view = SDKView()
        view.sdkBackgroundColor = Theme(for: self).seperatorColor

        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        let indent: CGFloat = 0

        NSLayoutConstraint.activate([
//            view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -(indent * 2)),
            view.heightAnchor.constraint(equalToConstant: 1),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: indent),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: indent),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public class func preferredSize(forContent content: Any?) -> CGSize {
        if let height = content as? Int {
            return CGSize(width: -1, height: height)
        }

        return CGSize(width: -1, height: 1)
    }

    override public var intrinsicContentSize: NSSize {
        NSSize(width: SDKView.noIntrinsicMetric, height: self.height)
    }
}
