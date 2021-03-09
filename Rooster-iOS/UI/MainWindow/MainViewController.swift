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

class MainViewController : UIViewController, UIPopoverPresentationControllerDelegate, MainViewControllerMacProtocols, DataModelAware, FirstRunViewControllerDelegate, UIActivityItemsConfigurationReading {
    
    let minimumContentSize = CGSize(width: 600, height: TimeRemainingViewController.preferredHeight)
     
    weak var delegate: MainViewControllerDelegate?
    
    private var contentViewController: UIViewController?
    private var loadingView: LoadingView?
    private var reloader: DataModelReloader?
   
    private func setToolbarItemsEnabled(_ enabled: Bool) {
        for item in self.toolbar.items {
            item.isEnabled = enabled
        }
    }
    
    private func addViewController(_ viewController: UIViewController) {
        self.removeLoadingView()

        self.addChild(viewController)

        self.view.addSubview(viewController.view)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        self.adjustWindowSize()
    }
    
    private func showEventListViewController() {
        #if targetEnvironment(macCatalyst)
        let viewController = MainEventListViewController()
        #else
        let viewController = self.navigationViewController
        #endif
        self.contentViewController = viewController

        self.addViewController(viewController)
    }
    
    func firstRunViewControllerShouldDismiss(_ firstRunViewController: FirstRunViewController) {
        firstRunViewController.view.removeFromSuperview()
        firstRunViewController.removeFromParent()
        self.contentViewController = nil
        self.showEventListViewController()
    }
    
    func firstRunViewControllerShowHelp(_ firstRunViewController: FirstRunViewController) {
        Controllers.showHelp(self)
    }
    
    func firstRunViewControllerShowSettings(_ firstRunViewController: FirstRunViewController) {
        self.togglePreferencesPopover(self)
    }
    
    func firstRunViewControllerShowCalendars(_ firstRunViewController: FirstRunViewController) {
        self.toggleCalendarsPopover(self)
    }

    private func showFirstRunViewController() {
        let viewController = FirstRunViewController()
        viewController.delegate = self
        
        self.contentViewController = viewController
        self.addViewController(viewController)
    }
    
    private func addLoadingView() {
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
    
    private func removeLoadingView() {
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
        
        self.removeLoadingView()
        self.setToolbarItemsEnabled(true)
        
        if Controllers.dataModelController.isAuthenticated {
            
            var savedState = SavedState()
            if savedState.bool(forKey: .firstRunWasPresented) {
                self.showEventListViewController()
                self.reloader = DataModelReloader(for: self)
            } else {
                savedState.setBool(true, forKey: .firstRunWasPresented)
                self.showFirstRunViewController()
            }
            
        } else {
            let alertController = UIAlertController(title: "CALENDAR_AUTHENTICATION_FAILED".localized,
                                                    message: "CALENDAR_AUTHENTICATION_FAILED_ACTION".localized,
                                                    preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
                exit(0)
            }))
            
            self.present(alertController, animated: true)
        }
    }

    func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
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

    @objc func showShareSheet(_ sender: Any?) {

        if let url = URL(string: "https://istweb.apple.com/rooster") {
            
            let shareSheet = UIActivityViewController(activityItems: [ "Rooster App:", url ],
                                                      applicationActivities: nil)
            
            shareSheet.excludedActivityTypes = [
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .assignToContact,
                .saveToCameraRoll,
                .postToFlickr,
                .postToVimeo,
                .postToTencentWeibo,
                .openInIBooks,
                .markupAsPDF]
            
            shareSheet.modalPresentationStyle = .fullScreen
            
            self.present(shareSheet, animated: true) {
            }
        }
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .flexibleSpace,
            .preferences,
            .flexibleSpace,
            .calendars,
            .flexibleSpace,
            .share,
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    lazy var calendarToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .calendars)
        item.image = UIImage(systemName: "calendar")
        item.label = "CALENDARS".localized
        item.action = #selector(toggleCalendarsPopover(_:))
        item.target = self
        item.isEnabled = false
        return item
    }()
    
    lazy var preferencesToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .preferences)
        
        let image = UIImage(systemName: "gearshape")
        item.image = image
        item.label = "PREFERENCES".localized
        item.action = #selector(togglePreferencesPopover(_:))
        item.target = self
        item.isEnabled = false
        return item
    }()
    
    var itemProvidersForActivityItemsConfiguration: [NSItemProvider] {

        let textProvider = NSItemProvider()
        textProvider.registerObject(ofClass: String.self, visibility: .all) { completion in
            completion("Rooster App: ", nil)
            return Progress.discreteProgress(totalUnitCount: 1)
        }

        
        let urlProvider = NSItemProvider()
        urlProvider.registerObject(ofClass: URL.self, visibility: .all) { completion in
            completion(URL(string: "https://istweb.apple.com/rooster"), nil)
            return Progress.discreteProgress(totalUnitCount: 1)
        }
        
        return [
            textProvider,
            urlProvider
        ]
    }


    lazy var shareToolbarItem: NSToolbarItem = {
//        let item = NSToolbarItem(itemIdentifier: .share)
//        item.image = UIImage(systemName: "square.and.arrow.up")
//        item.label = "Share"
//        item.action = #selector(showShareSheet(_:))
//        item.target = self
//        item.isEnabled = false
//
        let item = NSSharingServicePickerToolbarItem(itemIdentifier: .share)
        item.image = UIImage(systemName: "square.and.arrow.up")
        item.isEnabled = false
        item.activityItemsConfiguration = self
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

        case .share:
            toolbarItem = self.shareToolbarItem
            
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
        
        let leftImage = UIImage(systemName: "gearshape")
        
        let leftButton = UIBarButtonItem(image: leftImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(preferencesButtonClicked(_:)))
                                         
        navigationItem.leftBarButtonItem = leftButton

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"),
                                                                            style: .plain,
                                                                            target: self,
                                                                            action: #selector(calendarsButtonClicked(_:)))

        navigationItem.title = "ROOSTER".localized
        
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
    static let share = NSToolbarItem.Identifier("com.apple.commapps.rooster.share")
    static let preferences = NSToolbarItem.Identifier("com.apple.commapps.rooster.preferences")
    static let calendars = NSToolbarItem.Identifier("com.apple.commapps.rooster.showCalendars")
}
#endif
