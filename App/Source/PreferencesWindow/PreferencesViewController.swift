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

    lazy var rootView = PreferencesRootView()
    
    override func loadView() {
        self.view = self.rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.rootView.bottomBar.doneButton.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
        self.rootView.soundChoices.delegate = self
        
        
    }

    @objc func doneButtonPressed(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func soundChoicesViewPresentingViewController(_ view: SoundPreferencesView) -> UIViewController {
        return self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.preferredContentSize = self.rootView.intrinsicContentSize
    }
    
}

class PreferencesRootView : UIView {
    
    lazy var buttonsContainer = ButtonsContainerView(frame: CGRect.zero)
    lazy var notificationChoices =  NotificationChoicesView(frame: CGRect.zero)
    lazy var soundChoices = SoundPreferencesView(frame: CGRect.zero)
    lazy var topBar = TopBar(frame: CGRect.zero)
    lazy var bottomBar = BottomBar(frame: CGRect.zero)
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(self.soundChoices)
        self.addSubview(self.notificationChoices)
        self.addSubview(self.buttonsContainer)
        
        self.layout.addView(self.soundChoices)
        self.layout.addView(self.notificationChoices)
        self.layout.addView(self.buttonsContainer)

        self.topBar.addToView(self)
        self.bottomBar.addToView(self)
        
        self.topBar.addTitleView(withText: "Preferences")

        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 450, height:   self.layout.intrinsicContentSize.height +
                                            self.topBar.intrinsicContentSize.height +
                                            self.bottomBar.intrinsicContentSize.height)
    }

    lazy var layout = VerticalViewLayout(hostView: self,
                                         insets: UIEdgeInsets(top: self.topBar.preferredHeight + 20, left: 20, bottom: 20, right: 20),
                                         spacing: UIOffset(horizontal: 10, vertical: 10))
    
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.layout.updateConstraints()
        
        self.invalidateIntrinsicContentSize()
    }
}
