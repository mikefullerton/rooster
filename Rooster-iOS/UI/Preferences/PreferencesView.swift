//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

class PreferencesView: UIView {
    private var contentView: UIView?
    lazy var topBar = TopBar(frame: CGRect.zero)
    lazy var bottomBar = BottomBar(frame: CGRect.zero)

    init() {
        super.init(frame: CGRect.zero)

        self.topBar.addToView(self)
        self.bottomBar.addToView(self)
        self.topBar.addTitleView(withText: "PREFERENCES".localized)

        self.backgroundColor = UIColor.clear

        _ = self.bottomBar.addLeftButton(title: "RESET".localized)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addContentView(_ view: UIView) {
        self.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topBar.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

        self.contentView = view

        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        var size = CGSize(width: UIView.noIntrinsicMetric,
                          height: self.topBar.intrinsicContentSize.height + self.bottomBar.intrinsicContentSize.height)

        if let contentView = self.contentView {
            size.height += contentView.intrinsicContentSize.height
            size.width = contentView.intrinsicContentSize.width
        }

        return size
    }
}
