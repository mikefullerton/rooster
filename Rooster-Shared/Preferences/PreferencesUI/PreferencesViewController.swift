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

class PreferencesViewController : SDKViewController {

//    private let tabViewController: VerticalTabViewController
    private lazy var bottomBar = BottomBar(frame: CGRect.zero)
    
    private static let windowSize = CGSize(width: 800, height: 600)
    
    @IBOutlet var toolbar: NSToolbar?
    @IBOutlet var customToolbarSpacer: NSToolbarItem?
    
    private let preferencePanels: [PreferencePanel]
    private var currentPreferencePanel: PreferencePanel? = nil
    
    enum panelKey : Int, CaseIterable {
        case general
        case sounds
        case notifications
        case menubar
    }
    
    init() {
        
        self.preferencePanels = [
            GeneralPreferencePanel(),
            SoundsPreferencePanel(),
            NotificationsPreferencePanel(),
            MenuBarPreferencesPanel()
        ]

        super.init(nibName: nil, bundle: nil)
        self.preferredContentSize = Self.windowSize
        self.title = "Preferences"
    }
    
    convenience required init?(coder: NSCoder) {
        self.init()
    }
    
    private var currentViewController: SDKViewController? {
        return self.currentPreferencePanel as? SDKViewController
    }
    
    func setCurrentPanel(_ panelKey: panelKey) {
        if let currentViewController = self.currentViewController {
            currentViewController.view.removeFromSuperview()
            self.currentPreferencePanel = nil
        }
        
        let newCurrentPanel = self.preferencePanels[panelKey.rawValue]
        self.currentPreferencePanel = newCurrentPanel
        
        if let currentViewController = self.currentViewController {
            self.setCurrentView(currentViewController.view)
        }
        
        if let items = self.toolbar?.items {
            
            for item in items {
                if item.itemIdentifier == newCurrentPanel.toolbarButtonIdentifier {
                    
                    let selectedItem = toolbar!.selectedItemIdentifier
                    if selectedItem != item.itemIdentifier {
                        self.toolbar!.selectedItemIdentifier = item.itemIdentifier
                    }
                    
                    self.setTitle(item.label)
                }
            }
        }
    }
    
    private func setTitle(_ titleOrNil: String?) {
        if let title = titleOrNil {
            self.title = "Rooster Settings - \(title)"
        } else {
            self.title = "Rooster Settings"
        }
        
        self.view.window?.title = self.title!
    }
    
    @IBAction @objc func generalToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.general)
    }

    @IBAction @objc func soundsToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.sounds)
    }

    @IBAction @objc func notificationsToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.notifications)
    }

    @IBAction @objc func menuBarToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.menubar)
    }

    override func loadView() {
        
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.clear
        
        self.view = view

        for prefPanel in self.preferencePanels {
            if let viewController = prefPanel as? SDKViewController {
                self.addChild(viewController)
            }
        }
        
        self.addBottomBar()
        self.setCurrentPanel(.general)
    }
    
    @objc func doneButtonPressed(_ sender: SDKButton) {
        self.dismissWindow()
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

    private func setCurrentView(_ view: SDKView) {
        
        self.view.addSubview(view, positioned: .below, relativeTo: self.bottomBar)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
        
        view.setContentHuggingPriority(.windowSizeStayPut, for: .horizontal)
        view.setContentHuggingPriority(.windowSizeStayPut, for: .vertical)
    }
}


