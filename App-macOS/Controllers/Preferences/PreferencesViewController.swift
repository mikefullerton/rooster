//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import Cocoa

class PreferencesViewController : NSViewController, SoundPreferencesViewDelegate {

    private let tabViewController: VerticalTabViewController
    private lazy var bottomBar = BottomBar(frame: CGRect.zero)
    
    init() {
        let soundPreferencesView = SoundPreferencesView(frame: CGRect.zero)
        
        let items = [
            VerticalTabItem(title: "CALENDARS".localized,
                            icon: NSImage(systemSymbolName: "calendar", accessibilityDescription: "calendar"),
                            viewController: CalendarChooserViewController()),
            
            VerticalTabItem(title: "SOUNDS".localized,
                            icon: NSImage(systemSymbolName: "speaker.wave.3", accessibilityDescription: "sounds"),
                            view: soundPreferencesView),
            
            VerticalTabItem(title: "NOTIFICATIONS".localized,
                            icon: NSImage(systemSymbolName: "bell", accessibilityDescription: "sounds"),
                            view: NotificationChoicesView(frame: CGRect.zero))
        ]
        
        self.tabViewController = VerticalTabViewController(with: items,
                                                           buttonListWidth: 200)
        
        super.init(nibName: nil, bundle: nil)
        
        soundPreferencesView.delegate = self
        
        self.preferredContentSize = CGSize(width: 800, height: 600)
        self.title = "Preferences"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        self.view = view

        self.addBottomBar()
        self.addTabView()
    }
    
    @objc func doneButtonPressed(_ sender: NSButton) {
        self.dismissWindow()
    }

    @objc func resetButtonPressed(_ sender: NSButton) {
        AppDelegate.instance.preferencesController.preferences = Preferences()
    }
    
    func soundPreferencesView(_ view: SoundPreferencesView,
                              presentSoundPickerForSoundIndex soundIndex: SoundPreference.SoundIndex,
                              fromView: NSView) {
        
        SoundPickerViewController(withSoundPreferenceIndex: soundIndex).presentInModalWindow(fromWindow: self.view.window)
    }
    
    private func addBottomBar() {
        self.bottomBar.addToView(self.view)

        self.bottomBar.doneButton.target = self
        self.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))

        let leftButton = self.bottomBar.addLeftButton(title: "RESET".localized)
        leftButton.target = self
        leftButton.action = #selector(resetButtonPressed(_:))
    }

    private func addTabView() {
        self.addChild(self.tabViewController)
        
        let view = self.tabViewController.view
        self.view.addSubview(view, positioned: .below, relativeTo: self.bottomBar)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
    }
}


