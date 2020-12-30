//
//  SoundChooserView.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/29/20.
//

import Foundation
import UIKit

protocol SoundChooserViewControllerDelegate : AnyObject {
    func soundChooserViewControllerWillDismiss(_ controller: SoundChooserViewController)
    func soundChooserViewControllerWasDismissed(_ controller: SoundChooserViewController)
}

class SoundChooserViewController : UIViewController, SoundPickerTableViewControllerDelegate {

    weak var delegate: SoundChooserViewControllerDelegate?
    
    let soundPreferenceIndex: SoundPreference.SoundIndex
    
    init(withSoundPreferenceIndex index: SoundPreference.SoundIndex) {
        self.soundPreferenceIndex = index
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = UIColor.clear
        
        let _ = self.blurView
        
        self.addChild(self.soundPicker)
        self.containerView.addSubview(self.soundPicker.view)
        
        self.soundPicker.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.soundPicker.view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.soundPicker.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.soundPicker.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.soundPicker.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])

        self.view.addGestureRecognizer(self.gestureRecognizer)
    }
    
    lazy var blurView: UIView = {
        let view = UIView()
        
        self.view.addSubview(view)
        
        view.backgroundColor = UIColor.black
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        return view
    }()
    
    func setBlurViewVisible(_ visible: Bool) {
        if visible {
            if let superview = self.view.superview {
                let view = self.blurView
                
                superview.insertSubview(view, belowSubview: self.view)
                
//                superview.insertSubview(view, at: 0)
                
                view.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: superview.topAnchor),
                    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                    view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
                ])
            }
        } else {
            self.blurView.removeFromSuperview()
        }
    }
    
    lazy var soundPicker: SoundPickerTableViewController = {
        let controller = SoundPickerTableViewController(withSoundIndex: self.soundPreferenceIndex)
        controller.soundPickerDelegate = self
        return controller
    
    }()
    
    func soundPickerTableViewController(_ soundPicker: SoundPickerTableViewController, didSelectSound soundURL: URL) {
        self.animateOff()
    }

    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        return view
    }()
    
    func animateOn() {
        self.containerView.alpha = 0
        self.blurView.alpha = 0
        
        var frame = self.view.bounds
        frame.origin.x = frame.maxX
        frame.size.width = frame.size.width * 0.75
        
        self.containerView.frame = frame
        
        var destFrame = frame
        destFrame.origin.x = self.view.bounds.maxX - destFrame.size.width
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn){
            self.containerView.frame = destFrame
            self.containerView.alpha = 1.0
            self.blurView.alpha = 0.7
        }
    }
    
    func animateOff() {
        if let delegate = self.delegate {
            delegate.soundChooserViewControllerWillDismiss(self)
        }

        var destFrame = self.view.bounds
        destFrame.origin.x = destFrame.maxX
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.containerView.frame = destFrame
            self.containerView.alpha = 0.0
            self.blurView.alpha = 0.0
        }) { (view) in
            self.removeFromParent()
            self.view.removeFromSuperview()
            self.blurView.alpha = 0.0

            if let delegate = self.delegate {
                delegate.soundChooserViewControllerWasDismissed(self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animateOn()
    }
    
    @objc func wasTapped(_ sender: UITapGestureRecognizer) {
        
        let touch = sender.location(in: self.view)
        
        if !self.containerView.frame.contains(touch) {
            self.animateOff()
        }
    }
    
    lazy var gestureRecognizer : UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(wasTapped(_:)))
        
        return recognizer
    }()
}
