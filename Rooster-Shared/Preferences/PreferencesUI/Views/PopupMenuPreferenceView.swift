//
//  SinglePreferenceView.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/2/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

open class PopupMenuPreferenceView: SDKView {
    public typealias Callback = (_ popupMenuPreference: PopupMenuPreferenceView) -> Void

    private let updateCallback: Callback
    private let refreshCallback: Callback
    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    public var isEnabled = true {
        didSet { self.popupButton.isEnabled = isEnabled }
    }

    public init(withTitle title: String,
                menuItems: [String],
                refresh refreshCallback: @escaping Callback,
                update updateCallback: @escaping Callback) {
        self.refreshCallback = refreshCallback
        self.updateCallback = updateCallback

        super.init(frame: CGRect.zero)

        self.titleView.stringValue = title
        self.popupButton.addItems(withTitles: menuItems)

        self.addTitleView()
        self.addPopupMenuButton()

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.refresh()
        }

        self.refresh()
    }

    public lazy var titleView: SDKTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).labelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        var size = CGSize.zero
        size.width = SDKView.noIntrinsicMetric
        size.height = max(self.popupButton.intrinsicContentSize.height, self.titleView.intrinsicContentSize.height)
        return size
    }

    open func refresh() {
        self.refreshCallback(self)
    }

    lazy var popupButton: SystemPopUpMenuButton = {
        let button = SystemPopUpMenuButton()
        button.callback = { [weak self] _ in
            guard let self = self else { return }
            self.updateCallback(self)
        }
        return button
    }()

    public var selectedItemIndex: Int? {
        get { self.popupButton.indexOfSelectedItem }
        set { self.popupButton.selectItem(at: newValue ?? 0) }
    }
}

extension PopupMenuPreferenceView {
    fileprivate func addPopupMenuButton() {
        let view = self.popupButton
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.titleView.trailingAnchor, constant: 6),
            view.firstBaselineAnchor.constraint(equalTo: self.titleView.firstBaselineAnchor)
        ])
    }

    fileprivate func addTitleView() {
        let view = self.titleView
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
