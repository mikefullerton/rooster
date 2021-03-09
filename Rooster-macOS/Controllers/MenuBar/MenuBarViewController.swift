//
//  MenuBarViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import AppKit
import Foundation
import RoosterCore

public class MenuBarViewController: NSViewController, Loggable {
    let listViewController = MenuBarItemViewController()

    private let preferencesUpdateHandler = PreferencesUpdateHandler()

    private var scheduleUpdateHandler = ScheduleUpdateHandler()

    public weak var presentedInPopover: NSPopover?

    lazy var visualEffectView: NSVisualEffectView = {
        let visualEffectView = NSVisualEffectView(frame: CGRect.zero)
        visualEffectView.material =  .underWindowBackground // .titlebar //.headerView
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        return visualEffectView
    }()

    lazy var toolbar = MenuBarToolBar()

    override public func loadView() {
        self.view = self.visualEffectView

        self.view.addSubview(self.toolbar)
        self.toolbar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.toolbar.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])

        self.addChild(self.listViewController)

        let view = self.listViewController.view
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.toolbar.bottomAnchor)
        ])

        self.preferencesUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.listViewController.reloadData()
        }

        self.scheduleUpdateHandler.handler = { [weak self] _, _ in
            guard let self = self else { return }
            self.listViewController.reloadData()
        }

        self.listViewController.reloadData()
    }

    override public func preferredContentSizeDidChange(for viewController: NSViewController) {
        if viewController == self.listViewController {
            var size = viewController.preferredContentSize
            size.height += self.toolbar.intrinsicContentSize.height
            self.preferredContentSize = size
        }
    }
}
