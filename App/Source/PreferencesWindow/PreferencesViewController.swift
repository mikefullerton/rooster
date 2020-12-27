//
//  PreferencesViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/1/20.
//

import Foundation
import UIKit
import SwiftUI

class PreferencesViewController : UIViewController {

    lazy var buttonsContainer = ButtonsContainerView(frame: CGRect(x: 0, y: 0, width: ButtonsContainerView.buttonSize, height: ButtonsContainerView.buttonSize))
    
    lazy var notificationChoices =  NotificationChoicesView()
    
    lazy var soundChoices = SoundChoicesView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addTopSubview(view: self.soundChoices)
        self.view.addSubview(view: self.notificationChoices, belowView: self.soundChoices)
        self.view.addSubview(view: self.buttonsContainer, belowView: self.notificationChoices)
    }

    var calculatedSize: CGSize {
        var size = CGSize.zero
        size.width = Layout.width
        size.height = self.view.calculateLayoutSize(withInsets: Layout.insets).height
        return size
    }
}
