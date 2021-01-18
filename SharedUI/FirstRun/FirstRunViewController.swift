//
//  FirstRunViewController.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/17/21.
//

import Foundation

protocol FirstRunViewControllerDelegate : AnyObject {
    func firstRunViewControllerShouldDismiss(_ firstRunViewController: FirstRunViewController)
    func firstRunViewControllerShowHelp(_ firstRunViewController: FirstRunViewController)
    func firstRunViewControllerShowSettings(_ firstRunViewController: FirstRunViewController)
    func firstRunViewControllerShowCalendars(_ firstRunViewController: FirstRunViewController)
}

class FirstRunViewController: ViewController {
    
    weak var delegate: FirstRunViewControllerDelegate?
    
    init() {
        super.init(nibName: "FirstRunViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 500, height: 500)
    }
    
    @IBAction @objc func dismissSelf(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstRunViewControllerShouldDismiss(self)
        }
    }

    @IBAction @objc func showMoreInfo(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstRunViewControllerShowHelp(self)
        }
    }

    @IBAction @objc func showSettings(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstRunViewControllerShowSettings(self)
        }
    }

    @IBAction @objc func showCalendars(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.firstRunViewControllerShowCalendars(self)
        }
    }

    
    
}
