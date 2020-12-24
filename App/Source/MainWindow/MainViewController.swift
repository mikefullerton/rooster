//
//  MainViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit

#if targetEnvironment(macCatalyst)
protocol MainViewControllerMacProtocols : NSToolbarDelegate {}
#else
protocol MainViewControllerMacProtocols {}
#endif

class MainViewController : UIViewController, UIPopoverPresentationControllerDelegate, MainViewControllerMacProtocols {
    var contentViewController: UIViewController?
    var spinner: UIActivityIndicatorView?
    
    func configure() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalenderAuthentication(_:)), name: AppDelegate.CalendarDidAuthenticateEvent, object: nil)
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
    
    lazy var navigationViewController: UINavigationController = {
        
        let viewController = MainEventListViewController()
        
        let navigationItem = viewController.navigationItem
        
        let leftImage = UIImage(systemName: "gear")
        
        let leftButton = UIBarButtonItem(image: leftImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(preferencesButtonClicked(_:)))
                                         
        navigationItem.leftBarButtonItem = leftButton

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"),
                                                                                    style: .plain, target: self, action: #selector(calendarsButtonClicked(_:)))

        navigationItem.title = "Rooster"
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        
        navigationViewController.setNavigationBarHidden(false, animated:false)
        
        return navigationViewController
    }()
    
    func createMainViewsIfNeeded() {
        if self.contentViewController == nil {
            #if targetEnvironment(macCatalyst)
            self.contentViewController = MainEventListViewController()
            #else
            self.contentViewController = self.navigationViewController
            #endif

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
    
    @objc func preferencesButtonClicked(_ sender: Any) {
        
    }

    @objc func calendarsButtonClicked(_ sender: Any) {
        self.navigationViewController.pushViewController(CalendarsPopOverViewController(), animated: true)
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
    
    func showPopover(for viewController: UIViewController,
                     fromView view: UIView) {
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.popover

        if let presentationController = viewController.popoverPresentationController {
            presentationController.permittedArrowDirections = .up
            presentationController.sourceView = view
            presentationController.canOverlapSourceViewRect = true
        }

        self.present(viewController, animated: true) {
        }
    }
    
    lazy var calendarButtonSourceView: UIView = {
        let view = UIView(frame: CGRect(x:0, y: 35, width:10, height: 10))
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35.0),
            view.leadingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32.0)
        ])
        
        return view
    }()
    
    @objc func toggleCalendarsPopover(_ sender: Any?) {
        
        if self.presentedViewController != nil {
            self.presentedViewController?.dismiss(animated: true, completion: {
                
            })
        } else {
            let viewController = CalendarsPopOverViewController()
            viewController.preferredContentSize = viewController.calculatedSize
            self.showPopover(for: viewController,
                             fromView: self.calendarButtonSourceView)
        }
    }

    lazy var preferencesButtonSourceView: UIView = {
        let view = UIView(frame: CGRect(x:0, y: 35, width:10, height: 10))
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: view.frame.size.width),
            view.heightAnchor.constraint(equalToConstant: view.frame.size.height),
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35.0),
            view.leadingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -72.0)
        ])
        
        return view
    }()
    
    @objc func togglePreferencesPopover(_ sender: Any?) {
        
        if self.presentedViewController != nil {
            self.presentedViewController?.dismiss(animated: true, completion: {
                
            })
        } else {
            let viewController = PreferencesViewController()
            viewController.preferredContentSize = viewController.calculatedSize
            self.showPopover(for: viewController,
                             fromView: self.preferencesButtonSourceView)
        }
    }

    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .preferences,
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
            item.image = UIImage(systemName: "calendar")
            item.label = "Calendars"
            item.action = #selector(toggleCalendarsPopover(_:))
            item.target = self
            toolbarItem = item

        case .preferences:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "gear")
            item.label = "Preferences"
            item.action = #selector(togglePreferencesPopover(_:))
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
    static let preferences = NSToolbarItem.Identifier("com.apple.rooster.preferences")
    static let calendars = NSToolbarItem.Identifier("com.apple.rooster.showCalendars")
}
#endif
