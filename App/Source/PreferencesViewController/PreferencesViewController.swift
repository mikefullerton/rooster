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
        
//        self.preferredContentSize = self.rootView.intrinsicContentSize
    }
    
}


