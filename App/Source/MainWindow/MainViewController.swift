//
//  MainViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import UIKit

protocol MainViewControllerDelegate : AnyObject {
    func mainViewController(_ viewController: MainViewController, preferredContentSizeDidChange size: CGSize)
}


#if targetEnvironment(macCatalyst)
protocol MainViewControllerMacProtocols : NSToolbarDelegate {}
#else
protocol MainViewControllerMacProtocols {}
#endif

class MainViewController : UIViewController, UIPopoverPresentationControllerDelegate, MainViewControllerMacProtocols, DataModelAware {
    
    let minimumContentSize = CGSize(width: 600, height: TimeRemainingViewController.preferredHeight)
     
    private var reloader: DataModelReloader? = nil
    
    weak var delegate: MainViewControllerDelegate?
    
    private var contentViewController: UIViewController?
    
    func createMainViewsIfNeeded() {
        if self.contentViewController == nil {
            
            self.removeLoadingView()
            
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
            
            for item in self.toolbar.items {
                item.isEnabled = true
            }
            
            self.adjustWindowSize()
        }
    }
    
    var loadingView: LoadingView?

    func addLoadingView() {
        let view = LoadingView()
        self.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.loadingView = view
    }
    
    func removeLoadingView() {
        if let view = self.loadingView {
            view.removeFromSuperview()
            self.loadingView = nil
        }
    }
    
    override func loadView() {
        let view = ContentAwareView()
        view.autoresizesSubviews = true
        view.backgroundColor = Theme(for: self).windowBackgroundColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLoadingView()
        self.preferredContentSize = CGSize(width: 200, height: 200)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalenderAuthentication(_:)), name: AppDelegate.CalendarDidAuthenticateEvent, object: nil)
    }
    
    func adjustWindowSize() {
        
        var size = CGSize.zero
        
        if let contentViewController = self.contentViewController {
            size = contentViewController.preferredContentSize
        }
        
        print("Adjusting window size to: \(size)")
        self.preferredContentSize = self.adjustedSize(size)
    }
    

    private func adjustedSize(_ size: CGSize) -> CGSize {
        return  CGSize(width: max(self.minimumContentSize.width, size.width),
                       height: max(self.minimumContentSize.height, size.height))
    }
    
    override var preferredContentSize: CGSize {
        get {
            return super.preferredContentSize
        }
        set(size) {
            super.preferredContentSize = size
            if let delegate = self.delegate {
                delegate.mainViewController(self, preferredContentSizeDidChange: size)
            }
        }
    }
    
    @objc func handleCalenderAuthentication(_ notif: Notification) {
        
        if DataModelController.instance.isAuthenticated {
            self.createMainViewsIfNeeded()
            self.reloader = DataModelReloader(for: self)
        } else {
            let alertController = UIAlertController(title: "Failed to recieve permission to access calendars", message: "We can't do anything, we we will quit now", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                exit(0)
            }))
            
            self.present(alertController, animated: true)
        }
    }

    func dataModelDidReload(_ dataModel: DataModel) {
        self.adjustWindowSize()
    }

    #if targetEnvironment(macCatalyst)
    
    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()

    @objc func toggleCalendarsPopover(_ sender: Any?) {
        let viewController = CalendarChooserViewController()
        viewController.modalPresentationStyle = .formSheet
        self.present(viewController, animated: true) {
        }
    }

    @objc func togglePreferencesPopover(_ sender: Any?) {
        let viewController = PreferencesViewController()
        viewController.modalPresentationStyle = .formSheet
        self.present(viewController, animated: true) {
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
    
    lazy var calendarToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .calendars)
        item.image = UIImage(systemName: "calendar")
        item.label = "Calendars"
        item.action = #selector(toggleCalendarsPopover(_:))
        item.target = self
        item.isEnabled = false
        return item
    }()
    
    lazy var preferencesToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .preferences)
        item.image = UIImage(systemName: "gear")
        item.label = "Preferences"
        item.action = #selector(togglePreferencesPopover(_:))
        item.target = self
        item.isEnabled = false
        return item
    }()
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem?
        
        switch itemIdentifier {
        case .toggleSidebar:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        case .calendars:
            toolbarItem = self.calendarToolbarItem

        case .preferences:
            toolbarItem = self.preferencesToolbarItem

        default:
            toolbarItem = nil
        }
        
        toolbarItem?.isEnabled = false
        
        return toolbarItem
    }
    
    #else
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

    @objc func preferencesButtonClicked(_ sender: Any) {
        
    }

    @objc func calendarsButtonClicked(_ sender: Any) {
        self.navigationViewController.pushViewController(CalendarChooserViewController(), animated: true)
    }

    #endif
}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let preferences = NSToolbarItem.Identifier("com.apple.rooster.preferences")
    static let calendars = NSToolbarItem.Identifier("com.apple.rooster.showCalendars")
}
#endif
