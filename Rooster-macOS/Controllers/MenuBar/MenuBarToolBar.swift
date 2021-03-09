//
//  MenuBarToolBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import AppKit
import Foundation
import RoosterCore

public class MenuBarToolBar: NSView {
    private lazy var quitButton: Button = {
        let view = Button(systemSymbolName: "xmark", accessibilityDescription: "quit", target: self, action: #selector(quit(_:)))!
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: SimpleStackView = {
        let view = SimpleStackView(direction: .horizontal, insets: SDKEdgeInsets.ten, spacing: SDKOffset.ten)

        view.setContainedViews([
            Button(systemSymbolName: "eye", accessibilityDescription: "show", target: self, action: #selector(show(_:)))!,
            Button(systemSymbolName: "ladybug", accessibilityDescription: "file radar", target: self, action: #selector(radar(_:)))!,
            Button(systemSymbolName: "calendar", accessibilityDescription: "calendars", target: self, action: #selector(calendars(_:)))!,
            Button(systemSymbolName: "gearshape", accessibilityDescription: "preferences", target: self, action: #selector(preferences(_:)))!
        ])

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var titleView: NSTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).labelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBordered = false
        titleView.stringValue = "Rooster"
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()

    public init() {
        super.init(frame: CGRect.zero)

        self.addSubview(self.quitButton)
        self.addSubview(self.stackView)
        self.addSubview(self.titleView)

        NSLayoutConstraint.activate([
            self.quitButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            self.titleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            self.quitButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func show(_ sender: Any?) {
        AppControllers.shared.showMainWindow()
    }

    @objc func quit(_ sender: Any?) {
        AppControllers.shared.appDelegate.quitRooster()
    }

    @objc func join(_ sender: Any?) {
        AppControllers.shared.showCodeAlert()
    }

    @objc func radar(_ sender: Any?) {
        AppControllers.shared.showRadarAlert()
    }

    @objc func calendars(_ sender: Any?) {
        AppControllers.shared.showCalendarsWindow()
    }

    @objc func preferences(_ sender: Any?) {
        AppControllers.shared.showPreferencesWindow()
    }

    override public var intrinsicContentSize: NSSize {
        let size = CGSize(width: NSView.noIntrinsicMetric, height: 40)
        return size
    }
}
