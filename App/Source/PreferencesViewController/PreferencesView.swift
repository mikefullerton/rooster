//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

class PreferencesView : UIView {
    
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


