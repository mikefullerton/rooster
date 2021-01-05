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

    lazy var buttonsContainer = ButtonsContainerView(frame: self.view.bounds)
    lazy var notificationChoices =  NotificationChoicesView(frame: self.view.bounds)
    lazy var soundChoices = SoundPreferencesView(frame: self.view.bounds, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.soundChoices)
        self.view.addSubview(self.notificationChoices)
        self.view.addSubview(self.buttonsContainer)

        self.topBar.addToView(self.view)
        self.bottomBar.addToView(self.view)
        self.bottomBar.doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
        
        self.layout.addView(self.soundChoices)
        self.layout.addView(self.notificationChoices)
        self.layout.addView(self.buttonsContainer)
    }

    @objc func doneButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    lazy var bottomBar = BottomBar(frame: self.view.bounds)
    
    lazy var topBar = TopBar(frame: self.view.bounds, title: "Preferences")
    
    var calculatedSize: CGSize {
        var size:CGSize = CGSize.zero
        size.width = self.view.frame.size.width
        size.height = self.bottomBar.frame.maxY
        return size
    }
    
    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> UIViewController {
        return self
    }
    
    lazy var layout = VerticalViewLayout(hostView: self.view,
                                         insets: UIEdgeInsets(top: self.topBar.preferredHeight + 20, left: 20, bottom: 20, right: 20),
                                         spacing: UIOffset(horizontal: 10, vertical: 10))
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        self.layout.updateConstraints()
    }
}
