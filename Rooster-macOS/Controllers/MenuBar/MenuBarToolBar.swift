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
        let view = Button(systemSymbolName: "xmark",
                          accessibilityDescription: "quit",
                          target: self,
                          action: #selector(quit(_:)))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: SimpleStackView = {
        let view = SimpleStackView(direction: .horizontal, insets: SDKEdgeInsets.ten, spacing: SDKOffset.ten)

        view.setContainedViews([
            Button(systemSymbolName: "eye", accessibilityDescription: "show", target: self, action: #selector(show(_:))),
            Button(systemSymbolName: "calendar", accessibilityDescription: "calendars", target: self, action: #selector(calendars(_:))),
            Button(systemSymbolName: "gearshape", accessibilityDescription: "preferences", target: self, action: #selector(preferences(_:)))
        ])

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    public init() {
        super.init(frame: CGRect.zero)

        self.addQuitButton()
        self.addTitleView()
        self.addStackView()
    }

    func addQuitButton() {
        let view = self.quitButton
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10)
        ])
    }

    func addStackView() {
        let view = self.stackView
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
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

    public lazy var subTitleView: SDKTextField = {
        let titleView = NSTextField()
        titleView.isEditable = false
        titleView.textColor = Theme(for: self).secondaryLabelColor
        titleView.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        titleView.alignment = .right
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.drawsBackground = false
        titleView.isBordered = false
        return titleView
    }()

    public func updateTitle() {
        self.titleView.stringValue = "Today"
        self.subTitleView.stringValue = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
    }

    private lazy var titleViewContainer: SDKView = {
        let container = NSView()
        container.sdkBackgroundColor = NSColor.clear
        return container
    }()

    private func addTitleView() {
        let container = self.titleViewContainer
        let title = self.titleView
        let subTitle = self.subTitleView

        self.updateTitle()

        self.addSubview(container)
        container.addSubview(title)
        container.addSubview(subTitleView)

        container.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            container.widthAnchor.constraint(equalToConstant: self.subTitleView.intrinsicContentSize.width + 10),

            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -4),

            subTitleView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subTitleView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 0)
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
        AppControllers.shared.quitRooster()
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
