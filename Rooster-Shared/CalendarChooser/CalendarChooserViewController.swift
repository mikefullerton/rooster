//
//  LeftSideViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/8/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class CalendarChooserViewController: SDKViewController, CalendarToolbarViewDelegate {
    private static let minSize = CGSize(width: 300, height: 100)
    private lazy var calendarsViewController = PersonalCalendarListViewController()
    private lazy var delegateCalendarsViewController = DelegateCalendarListViewController()
    private var activeViewController: CalendarListViewController?

    private lazy var topBar = CalendarToolbarView()
    private lazy var bottomBar = BottomBar()

    override public func loadView() {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        self.view = view

        self.addTopBar()
        self.addBottomBar()
        self.topBar.delegate = self

        self.addChild(self.calendarsViewController)
        self.addChild(self.delegateCalendarsViewController)
        self.activateViewController(self.calendarsViewController)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.updatePreferredContentSize()

        self.title = "Rooster Calendar Chooser"
    }

    func updatePreferredContentSize() {
        self.calendarsViewController.reloadData()
        self.delegateCalendarsViewController.reloadData()

        let calendarSize = self.calendarsViewController.viewModelContentSize
        let delegateCalendarsSize = self.delegateCalendarsViewController.viewModelContentSize

        var size = Self.minSize

        size.width = max(size.width, calendarSize.width)
        size.width = max(size.width, delegateCalendarsSize.width)

        size.height = max(size.height, calendarSize.height)
        size.height = max(size.height, delegateCalendarsSize.height)

        size.height += self.topBar.preferredHeight + self.bottomBar.preferredHeight

        size.width += 20

        self.preferredContentSize = size
    }

    private func activateViewController(_ viewController: CalendarListViewController) {
        if let activeViewController = self.activeViewController {
            activeViewController.view.removeFromSuperview()
        }

        viewController.scrollView?.contentInsets = NSEdgeInsets(top: self.topBar.preferredHeight,
                                                                left: 0,
                                                                bottom: self.bottomBar.preferredHeight,
                                                                right: 0)

        self.setContentView(viewController.view)
        self.activeViewController = viewController
    }

    public func calendarToolbarView(_ toolbarView: CalendarToolbarView, didChangeSelectedIndex index: Int) {
        if index == 0 {
            self.activateViewController(self.calendarsViewController)
        } else {
            self.activateViewController(self.delegateCalendarsViewController)
        }
    }

    private func addTopBar() {
        let view = self.topBar
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: view.preferredHeight),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    private func setContentView(_ view: SDKView) {
        self.view.addSubview(view, positioned: .below, relativeTo: self.topBar)

        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topBar.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }

    @objc func resetButtonPressed(_ sender: SDKButton) {
        self.activeViewController?.toggleAll()
    }

    @objc func doneButtonPressed(_ sender: SDKButton) {
        self.hideWindow()
    }

    private func addBottomBar() {
        self.bottomBar.addToView(self.view)

        self.bottomBar.doneButton.target = self
        self.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))

        let leftButton = self.bottomBar.addLeftButton(title: "TOGGLE_ALL".localized)
        leftButton.target = self
        leftButton.action = #selector(resetButtonPressed(_:))
    }
}
