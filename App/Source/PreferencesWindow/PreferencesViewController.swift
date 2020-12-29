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

    static private let width: CGFloat = 400.0
    
    private let containerFrame  = CGRect(x: 0,
                                         y: 0,
                                         width: PreferencesViewController.width,
                                         height: CGFloat.greatestFiniteMagnitude)
    
    lazy var buttonsContainer = ButtonsContainerView(frame: self.containerFrame)
    lazy var notificationChoices =  NotificationChoicesView(frame: self.containerFrame)
    lazy var soundChoices = SoundChoicesView(frame: self.containerFrame, delegate: self)


    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.layout.addSubview(self.soundChoices)
        self.layout.addSubview(self.notificationChoices)
        self.layout.addSubview(self.buttonsContainer)
    }

    lazy var layout: ViewLayout = {
        return VerticalViewLayout(hostView: self.view,
                                  insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                                  spacing: UIOffset(horizontal: 10, vertical: 10))
        
    }()
    
    var calculatedSize: CGSize {
        var size =  self.layout.size
        size.width = PreferencesViewController.width
        return size
    }
    
    func soundChoicesView(_ view: SoundChoicesView,
                          presentSoundChooser soundChooser: SoundChooserViewController,
                          fromView: UIView) {
    
        self.addChild(soundChooser)
        self.view.addSubview(soundChooser.view)

        soundChooser.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            soundChooser.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            soundChooser.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            soundChooser.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            soundChooser.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        self.view.setNeedsLayout()
        
//
//        soundChooser.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//
//        if let presentationController = self.popoverPresentationController {
//            presentationController.permittedArrowDirections = .left
//            presentationController.sourceView = fromView
//            presentationController.canOverlapSourceViewRect = true
//        }
//
//        self.present(soundChooser, animated: true) {
//        }
        
    }

}
