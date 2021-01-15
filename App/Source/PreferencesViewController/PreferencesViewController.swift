//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit
import SwiftUI

class PreferencesViewController : UIViewController, SoundChoicesViewDelegate {

    lazy var rootView = PreferencesView()
    
    let tabViewController: VerticalTabViewController
    
    init() {
        
        let soundPreferencesView = SoundPreferencesView(frame: CGRect.zero)
        let notificationPreferencesViw = NotificationChoicesView(frame: CGRect.zero)
        
        let items = [
            VerticalTabItem(title: "Sounds", icon: nil, view: soundPreferencesView),
            VerticalTabItem(title: "Notifications", icon: nil, view: notificationPreferencesViw)
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
        
        self.view.backgroundColor = Theme(for: self.view).preferencesViewColor
            
        self.addChild(self.tabViewController)
        
        self.rootView.addContentView(self.tabViewController.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.rootView.bottomBar.doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
        self.rootView.bottomBar.leftButton.addTarget(self, action: #selector(resetButtonPressed(_:)), for: .touchUpInside)
    }

    @objc func doneButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func resetButtonPressed(_ sender: UIButton) {
        AppDelegate.instance.preferencesController.preferences = Preferences()
    }

    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> UIViewController {
        return self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.preferredContentSize = self.rootView.intrinsicContentSize
    }
    
    
}


