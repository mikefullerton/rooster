//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import Cocoa

class PreferencesViewController : NSViewController, SoundChoicesViewDelegate {

    lazy var rootView = PreferencesView()
    
    let tabViewController: VerticalTabViewController
    
    init() {
        
        let soundPreferencesView = SoundPreferencesView(frame: CGRect.zero)
        let notificationPreferencesViw = NotificationChoicesView(frame: CGRect.zero)
        
        let items = [
            VerticalTabItem(title: "SOUNDS".localized, icon: nil, view: soundPreferencesView),
            VerticalTabItem(title: "NOTIFICATIONS".localized, icon: nil, view: notificationPreferencesViw)
        ]
        
        self.tabViewController = VerticalTabViewController(with: items)
        
        super.init(nibName: nil, bundle: nil)
        
        soundPreferencesView.delegate = self
        
        self.preferredContentSize = CGSize(width: 800, height: 600)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.rootView
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = Theme(for: self.view).preferencesViewColor.cgColor
            
        self.addChild(self.tabViewController)
        
        self.rootView.addContentView(self.tabViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.rootView.bottomBar.doneButton.target = self
        self.rootView.bottomBar.doneButton.action = #selector(doneButtonPressed(_:))
        
        self.rootView.bottomBar.leftButton.target = self
        self.rootView.bottomBar.leftButton.action = #selector(resetButtonPressed(_:))
    }

    @objc func doneButtonPressed(_ sender: NSButton) {
//        self.presentingViewController?.dismiss(self)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        self.view.window?.orderOut(self)
        NSApp.stopModal(withCode: .OK)
    }

    @objc func resetButtonPressed(_ sender: NSButton) {
        AppDelegate.instance.preferencesController.preferences = Preferences()
    }

    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> NSViewController {
        return self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
//        self.preferredContentSize = self.rootView.intrinsicContentSize
    }
    
    
}


