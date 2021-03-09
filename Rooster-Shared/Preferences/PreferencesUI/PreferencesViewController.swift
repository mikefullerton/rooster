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
    private var currentPreferencePanel: PreferencePanel?
    
    enum PanelKey : String, CaseIterable {
        case general
        case calendars
        case events
        case reminders
        case sounds
        case notifications
        case menubar
    }
    
    init() {
        
        self.preferencePanels = [
            GeneralPreferencePanel(),
            CalendarPreferencePanel(),
            EventsPreferencePanel(),
            RemindersPreferencePanel(),
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
    
    func panelForKey(_ panelKey: PanelKey) -> PreferencePanel? {
        if let index = self.preferencePanels.firstIndex(where: { $0.toolbarButtonIdentifier == panelKey.rawValue }) {
            return self.preferencePanels[index]
        }
        
        return nil
    }
    
    func toolbarItemForKey(_ panelKey: PanelKey) -> NSToolbarItem? {
        if let items = self.toolbar?.items {
            
            for item in items where item.itemIdentifier.rawValue == panelKey.rawValue {
                return item
            }
        }
        
        return nil
    }
    
    func setCurrentPanel(_ panelKey: PanelKey) {
        if  let newCurrentPanel = self.panelForKey(panelKey),
            let toolbarItem = self.toolbarItemForKey(panelKey) {
           
            if let currentViewController = self.currentPreferencePanel {
                currentViewController.view.removeFromSuperview()
                self.currentPreferencePanel = nil
            }
           
            self.currentPreferencePanel = newCurrentPanel
            
            if let currentViewController = self.currentPreferencePanel {
                self.setCurrentView(currentViewController.view)
            }
            
            self.toolbar!.selectedItemIdentifier = toolbarItem.itemIdentifier
            self.setTitle(toolbarItem.label)
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
    
    @IBAction func generalToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.general)
    }

    @IBAction func soundsToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.sounds)
    }

    @IBAction func notificationsToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.notifications)
    }

    @IBAction func menuBarToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.menubar)
    }

    @IBAction func calendarToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.calendars)
    }

    @IBAction func eventsToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.events)
    }

    @IBAction func reminderToolbarItemChosen(_ sender: NSToolbarItem?) {
        self.setCurrentPanel(.reminders)
    }
    
    override func loadView() {
        
        let view = SDKView()
        view.sdkBackgroundColor = SDKColor.clear
        
        self.view = view

        for prefPanel in self.preferencePanels {
            self.addChild(prefPanel)
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


