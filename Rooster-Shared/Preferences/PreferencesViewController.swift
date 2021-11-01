//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public class PreferencesViewController: SDKViewController, PreferencesToolbarDelegate {
    let insets = SDKEdgeInsets.ten

    private lazy var bottomBar = BottomBar(frame: CGRect.zero)

    private static let windowSize = CGSize(width: 800, height: 800)

    private lazy var toolbar: PreferencesToolbar = {
        let view = PreferencesToolbar(withPreferencePanels: self.preferencePanels)
        view.delegate = self
        return view
    }()

#if REMINDERS
    private lazy var preferencePanels: [PreferencePanel] = {
        [
            GeneralPreferencePanel(),
            TodayWindowPreferencesPanel(),
            MenuBarPreferencesPanel(),
            RemindersPreferencePanel(),
            SoundsPreferencePanel(),
            NotificationsPreferencePanel(),
            KeyboardShortcutsPanel()
        ]
    }()
#else
    private lazy var preferencePanels: [PreferencePanel] = {
        [
            GeneralPreferencePanel(),
            TodayWindowPreferencesPanel(),
            MenuBarPreferencesPanel(),
            SoundsPreferencePanel(),
            NotificationsPreferencePanel(),
            KeyboardShortcutsPanel()
        ]
    }()
#endif

    private var currentPreferencePanel: PreferencePanel?

    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "Preferences"
    }

    required convenience init?(coder: NSCoder) {
        self.init()
    }

    public func preferencesToolbar(_ toolbar: PreferencesToolbar, panelDidChange panel: PreferencePanel) {
        self.setCurrentPanel(panel)
    }

    func setCurrentPanel(_ panel: PreferencePanel) {
        if let currentViewController = self.currentPreferencePanel {
            if panel == currentViewController {
                return
            }

            currentViewController.view.removeFromSuperview()
            currentViewController.isSelected = false
            self.currentPreferencePanel = nil
        }

        self.currentPreferencePanel = panel

        if let currentViewController = self.currentPreferencePanel {
            panel.isSelected = true
            self.setCurrentView(currentViewController.view)
        }

//        self.toolbar!.selectedItemIdentifier = panel.toolBarItem.itemIdentifier
        self.setTitle(panel.buttonTitle)
    }

    private func setTitle(_ titleOrNil: String?) {
        if let title = titleOrNil {
            self.title = "Rooster Settings - \(title)"
        } else {
            self.title = "Rooster Settings"
        }

        self.view.window?.title = self.title!
    }

    override public func loadView() {
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.clear

        self.view = view

        self.addTopBar()
        self.addBottomBar()
        self.setCurrentPanel(self.preferencePanels[0])
        self.preferredContentSize = Self.windowSize
    }

    @objc func doneButtonPressed(_ sender: SDKButton) {
        self.hideWindow()
    }

    @objc func resetButtonPressed(_ sender: SDKButton) {
        if let currentPanel = self.currentPreferencePanel {
            currentPanel.resetButtonPressed()
        }
    }

    private func addTopBar() {
        self.view.addSubview(self.toolbar)
        self.toolbar.activateConstraints(.fillTop)
    }

    private func addBottomBar() {
        self.bottomBar.addToView(self.view)

        self.bottomBar.doneButton.target = self
        self.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))

        let leftButton = self.bottomBar.addLeftButton(title: "RESET_TO_DEFAULTS".localized)
        leftButton.target = self
        leftButton.action = #selector(resetButtonPressed(_:))
    }

    private func setCurrentView(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(view, positioned: .below, relativeTo: self.bottomBar)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.toolbar.bottomAnchor, constant: self.insets.top),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.insets.left),

//            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
//            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)

            view.widthAnchor.constraint(equalToConstant: Self.windowSize.width - self.insets.left - self.insets.right),
            view.heightAnchor.constraint(equalToConstant: Self.windowSize.height - self.insets.top - self.insets.bottom)
        ])

        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
}
