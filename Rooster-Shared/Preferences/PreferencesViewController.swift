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

public class PreferencesViewController: SDKViewController {
    private lazy var bottomBar = BottomBar(frame: CGRect.zero)

    private static let windowSize = CGSize(width: 800, height: 600)

    @IBOutlet private var toolbar: NSToolbar!
    @IBOutlet private var customToolbarSpacer: NSToolbarItem?

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

//    func panel(forName panelName: String) -> PreferencePanel? {
//        if let index = self.preferencePanels.firstIndex(where: { $0.buttonTitle == panelName }) {
//            return self.preferencePanels[index]
//        }
//
//        return nil
//    }
//
//    func toolbarItem(forName panelName: String) -> NSToolbarItem? {
//        if let items = self.toolbar?.items {
//            for item in items where item.itemIdentifier.rawValue == panelName {
//                return item
//            }
//        }
//
//        return nil
//    }

    func setCurrentPanel(_ panel: PreferencePanel) {
        if let currentViewController = self.currentPreferencePanel {
            currentViewController.view.removeFromSuperview()
            self.currentPreferencePanel = nil
        }

        self.currentPreferencePanel = panel

        if let currentViewController = self.currentPreferencePanel {
            self.setCurrentView(currentViewController.view)
        }

        self.toolbar!.selectedItemIdentifier = panel.toolBarItem.itemIdentifier
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

        self.toolbar.delegate = self

        for prefPanel in self.preferencePanels.reversed() {
            let toolbarItem = prefPanel.toolBarItem

            self.toolbar.insertItem(withItemIdentifier: toolbarItem.itemIdentifier, at: 0)

            prefPanel.callback = { [weak self] panel in
                self?.setCurrentPanel(panel)
            }
            self.addChild(prefPanel)
        }

        assert(self.toolbar.items.count == self.preferencePanels.count, "didn't insert")

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

    private func addBottomBar() {
        self.bottomBar.addToView(self.view)

        self.bottomBar.doneButton.target = self
        self.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))

        let leftButton = self.bottomBar.addLeftButton(title: "RESET".localized)
        leftButton.target = self
        leftButton.action = #selector(resetButtonPressed(_:))
    }

    let insets = SDKEdgeInsets.ten

    private func setCurrentView(_ view: SDKView) {
        view.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(view, positioned: .below, relativeTo: self.bottomBar)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.insets.top),
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

extension PreferencesViewController: NSToolbarDelegate {
    public func toolbar(_ toolbar: NSToolbar,
                        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                        willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let index = self.preferencePanels.firstIndex(where: { $0.toolBarItem.itemIdentifier == itemIdentifier }) {
            return self.preferencePanels[index].toolBarItem
        }
        return nil
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        self.preferencePanels.map { $0.toolBarItem.itemIdentifier }
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        self.preferencePanels.map { $0.toolBarItem.itemIdentifier }
    }

    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        self.preferencePanels.map { $0.toolBarItem.itemIdentifier }
    }
}
