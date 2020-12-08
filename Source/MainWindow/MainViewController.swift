//
//  MainViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit

class MainViewController : UIViewController {
    
    var mainSplitViewController: MainSplitViewController?
    var toolbar: UIToolbar?
    var spinner: UIActivityIndicatorView?
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalenderAuthentication(_:)), name: AlarmController.CalendarDidAuthenticateEvent, object: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    func createMainViewsIfNeeded() {
        if self.mainSplitViewController == nil {
            
            self.mainSplitViewController = MainSplitViewController()
            
            self.addChild(self.mainSplitViewController!)

            if let subview = self.mainSplitViewController!.view {
                self.view.addSubview(subview)

                subview.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    subview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    subview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    subview.topAnchor.constraint(equalTo: self.view.topAnchor),
                    subview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                ])
            }
        }
    }
    
    func addSpinner() {
        
        if self.spinner != nil {
            return
        }
        
        let spinner = UIActivityIndicatorView(style: .large)
        self.view.addSubview(spinner)
        
        spinner.sizeToFit()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: spinner.frame.size.width),
            spinner.heightAnchor.constraint(equalToConstant: spinner.frame.size.height),
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        spinner.isHidden = false
        spinner.startAnimating()
        self.spinner = spinner
    }
    
    func removeSpinner() {
        if self.spinner != nil {
            self.spinner!.removeFromSuperview()
            self.spinner = nil
        }
    }
    
    override func loadView() {
        let view = UIView()
        view.autoresizesSubviews = true
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
    }
    
    override func viewDidLoad() {
        self.addSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func handleCalenderAuthentication(_ notif: Notification) {
        self.removeSpinner()
        
        if EventKitDataModelController.instance.isAuthenticated {
            self.createMainViewsIfNeeded()
        } else {
            let alertController = UIAlertController(title: "Failed to recieve permission to access calendars", message: "We can't do anything, we we will quit now", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                exit(0)
            }))
            
            self.present(alertController, animated: true)
        }
    }
    
    
    
}
