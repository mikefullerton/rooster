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

    lazy var buttonsContainer = ButtonsContainerView(frame: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: ButtonsContainerView.buttonSize,
                                                                   height: ButtonsContainerView.buttonSize))
    
    lazy var notificationChoices =  NotificationChoicesView(frame: CGRect(x: 0,
                                                                          y: 0,
                                                                          width:self.layout.layoutSpec.width,
                                                                          height: CGFloat.greatestFiniteMagnitude))
    
    lazy var soundChoices = SoundChoicesView(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width:self.layout.layoutSpec.width,
                                                           height: CGFloat.greatestFiniteMagnitude))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout.addSubview(self.soundChoices)
        self.layout.addSubview(self.notificationChoices)
        self.layout.addSubview(self.buttonsContainer)
    }

    lazy var layout: VerticalStackedViewLayout = {
        return VerticalStackedViewLayout(hostView: self.view,
                                         layoutSpec: ViewLayoutSpec.default)
        
    }()
    
    var calculatedSize: CGSize {
        let size =  self.layout.layoutSize
        
        return size
    }
}
