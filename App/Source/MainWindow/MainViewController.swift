//
//  MainViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit

class MainViewController : UIViewController, NSToolbarDelegate, UIPopoverPresentationControllerDelegate {
    
    var contentViewController: UIViewController?
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
        if self.contentViewController == nil {
            
            self.contentViewController = RightSideViewController()
            
            self.addChild(self.contentViewController!)

            if let subview = self.contentViewController!.view {
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
    
    #if targetEnvironment(macCatalyst)

    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()
    
    @objc
    func showCalendars(_ sender: Any?) {
        
        if self.presentedViewController != nil {
            self.presentedViewController?.dismiss(animated: true, completion: {
                
            })
        } else {
            let viewController = CalendarsPopOverViewController()
            
            viewController.preferredContentSize = viewController.calculatedSize
            
            viewController.modalPresentationStyle = UIModalPresentationStyle.popover

            if let presentationController = viewController.popoverPresentationController {
                presentationController.permittedArrowDirections = .up
                presentationController.sourceView = self.view
                presentationController.canOverlapSourceViewRect = true
                
                let bounds = self.view.bounds
                let sourceRect = CGRect(x: bounds.size.width - 32,
                                        y: 35,
                                        width: 10,
                                        height: 10)
                presentationController.sourceRect = sourceRect
            }

            self.present(viewController, animated: true) {
            }
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
//            .toggleSidebar,
            .flexibleSpace,
            .calendars,
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem?
        
        switch itemIdentifier {
        case .toggleSidebar:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        case .calendars:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
//            item.view = UIButton()
            item.image = UIImage(systemName: "calendar")
            item.label = "Edit Calendars"
            item.action = #selector(showCalendars(_:))
            item.target = self
            toolbarItem = item
            
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }
    
    #endif
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let calendars = NSToolbarItem.Identifier("com.apple.rooster.showCalendars")
}
#endif
