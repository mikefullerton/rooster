//
//  PreferencesView.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/9/21.
//

import Foundation
import UIKit

class PreferencesView : UIView {
    private var contentView: UIView?
    lazy var topBar = TopBar(frame: CGRect.zero)
    lazy var bottomBar = BottomBar(frame: CGRect.zero)
        
    init() {
        super.init(frame: CGRect.zero)

        self.topBar.addToView(self)
        self.bottomBar.addToView(self)
        self.topBar.addTitleView(withText: "Preferences")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addContentView(_ view: UIView) {
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topBar.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomBar.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        self.contentView = view
        
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        
        var size = CGSize(width: UIView.noIntrinsicMetric,
                          height: self.topBar.intrinsicContentSize.height + self.bottomBar.intrinsicContentSize.height)
        
        if let contentView = self.contentView {
            size.height += contentView.intrinsicContentSize.height
            size.width = contentView.intrinsicContentSize.width
        }
        
        return size
    }
}

class OldPreferencesView : UIView {
    
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
        
        self.layout.setViews([
            self.soundChoices,
            self.notificationChoices,
            self.buttonsContainer
        ])
        
        self.topBar.addToView(self)
        self.bottomBar.addToView(self)
        
        self.topBar.addTitleView(withText: "Preferences")
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
    
    
}



