//
//  MainWindowToolbar.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/17/21.
//

import AppKit
import Foundation
import RoosterCore

// swiftlint:disable file_types_order

public class MainWindowToolbar: NSTitlebarAccessoryViewController, Loggable {
    let preferredHeight = CGFloat(40)

    let scheduleReloader = ScheduleUpdateHandler()

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.layoutAttribute = .left
        self.automaticallyAdjustsSize = true
        self.isHidden = false
        self.fullScreenMinHeight = self.preferredHeight
        self.view.sdkBackgroundColor = NSColor.clear

        self.view.translatesAutoresizingMaskIntoConstraints = false

        self.addTitleView()
        self.addRightSideButtons()
   //     self.addFilterButton()

        self.scheduleReloader.handler = { _, _ in
            self.updateTitle()
        }
    }

    override public func viewDidLayout() {
        super.viewDidLayout()

        DispatchQueue.main.async { self.fixSize() }
    }

    override public func viewWillAppear() {
        super.viewWillAppear()

        DispatchQueue.main.async { self.fixSize() }

        self.updateTitle()
    }

    var centerOffset: CGFloat {
        let frameInWindow = view.convert(self.view.frame, from: nil)
        return (frameInWindow.origin.x / 2.0) * -1.0
    }

    func fixSize() {
        guard let window = self.view.window else { return }

        let view = self.view
        var frame = view.frame

        let frameInWindow = view.convert(frame, from: nil)

        let windowFrame = window.frame

        guard windowFrame.size.height > 0, windowFrame.width > 0 else {
            DispatchQueue.main.async { self.fixSize() }
            return
        }

        frame.size.width = (windowFrame.size.width + frameInWindow.origin.x) // origin is negative
        view.frame = frame

        self.titleViewContainer.deactivateConstraint(forAnchor: self.titleViewContainer.centerXAnchor)
        NSLayoutConstraint.activate([
            self.titleViewContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -self.centerOffset)
        ])
    }

    private let buttonConfig = NSImage.SymbolConfiguration(scale: .large)

    private lazy var rightSizeButtons: SimpleStackView = {
        let view = SimpleStackView(direction: .horizontal,
                                   insets: SDKEdgeInsets.twenty,
                                   spacing: SDKOffset(horizontal: 14, vertical: 0))

        view.setContainedViews([
            Button(systemSymbolName: "calendar",
                   accessibilityDescription: "Open Calendar Window",
                   symbolConfiguration: self.buttonConfig) { _ in
                AppControllers.shared.showCalendarsWindow()
            },

            Button(systemSymbolName: "gearshape",
                   accessibilityDescription: "Show Preferences Window",
                   symbolConfiguration: self.buttonConfig) { _ in
                AppControllers.shared.showPreferencesWindow()
            }
        ])

        return view
    }()

    private func addRightSideButtons() {
        let view = self.rightSizeButtons
        self.view.addSubview(view)
        view.activateConstraints(.trailing)
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

    private lazy var filterButton: Button = {
        let menuItems: [NSMenuItem] = [
            MenuItem(title: "Low") { _ in
            }
        ]

        let view = PopUpMenuButton(systemSymbolName: "line.horizontal.3",
                                   accessibilityDescription: "Filter Schedule",
                                   symbolConfiguration: self.buttonConfig,
                                   menuItems: menuItems)
        return view
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

        self.view.addSubview(container)
        container.addSubview(title)
        container.addSubview(subTitleView)

        container.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        subTitle.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: self.view.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            container.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -self.centerOffset),
            container.widthAnchor.constraint(equalToConstant: self.subTitleView.intrinsicContentSize.width + 10),

            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -4),

            subTitleView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subTitleView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 0)
        ])
    }

    private func addFilterButton() {
        let view = self.filterButton
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10)
        ])
    }
}

public class MainWindowToolbarView: ContentAwareView {
//    override public var intrinsicContentSize: NSSize {
//        CGSize(width: NSView.noIntrinsicMetric, height: 40)
//    }
}
