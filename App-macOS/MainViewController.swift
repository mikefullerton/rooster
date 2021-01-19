//
//  MainViewController.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/20/20.
//

import Foundation
import Cocoa

protocol MainViewControllerDelegate : AnyObject {
    func mainViewController(_ viewController: MainViewController, preferredContentSizeDidChange size: CGSize)
}

class MainViewController : NSViewController,
                           DataModelAware,
                           FirstRunViewControllerDelegate,
                           NSToolbarDelegate {
    
    //UIPopoverPresentationControllerDelegate
    // , UIActivityItemsConfigurationReading
    
    let minimumContentSize = CGSize(width: 500, height: 600) //CGSize(width: 600, height: TimeRemainingViewController.preferredHeight)
     
    weak var delegate: MainViewControllerDelegate?
    
    private var contentViewController: NSViewController?
    private var mainWindowController: MainWindowController?
    private var reloader: DataModelReloader? = nil
   
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nil, bundle: nil)
        self.preferredContentSize = CGSize(width: 200, height: 200)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer?.backgroundColor = NSColor.red.cgColor
        
        self.addLoadingView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCalenderAuthentication(_:)), name: AppDelegate.CalendarDidAuthenticateEvent, object: nil)
    }
    
    func configure() {
        
    }
    
    private func setToolbarItemsEnabled(_ enabled: Bool) {
//        for item in self.toolbar.items {
//            item.isEnabled = enabled
//        }
    }
    
    private func addViewController(_ viewController: NSViewController) {
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
//        let viewController = MainEventListViewController()
//        self.contentViewController = viewController
//        self.addViewController(viewController)
    }
    
    func firstRunViewControllerShouldDismiss(_ firstRunViewController: FirstRunViewController) {
        firstRunViewController.view.removeFromSuperview()
        firstRunViewController.removeFromParent()
        self.contentViewController = nil
        self.showEventListViewController()
    }
    
    func firstRunViewControllerShowHelp(_ firstRunViewController: FirstRunViewController) {
        AppDelegate.instance.showHelp(self)
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
    
//    override func loadView() {
//        let view = ContentAwareView()
//        view.autoresizesSubviews = true
//        view.backgroundColor = Theme(for: self).windowBackgroundColor
//        self.view = view
//    }
        
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
        
        if AppDelegate.instance.dataModelController.isAuthenticated {
            
            var savedState = SavedState()
            if savedState.bool(forKey: .firstRunWasPresented) {
                self.showEventListViewController()
                self.reloader = DataModelReloader(for: self)
            } else {
                savedState.setBool(true, forKey: .firstRunWasPresented)
                self.showFirstRunViewController()
            }
            
        } else {
//            let alertController = UIAlertController(title: "CALENDAR_AUTHENTICATION_FAILED".localized,
//                                                    message: "CALENDAR_AUTHENTICATION_FAILED_ACTION".localized,
//                                                    preferredStyle: UIAlertController.Style.alert)
//
//            alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
//                exit(0)
//            }))
//
//            self.present(alertController, animated: true)
        }
    }

    func dataModelDidReload(_ dataModel: DataModel) {
        self.adjustWindowSize()
    }

    lazy var toolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()

    @objc func toggleCalendarsPopover(_ sender: Any?) {
//        let viewController = CalendarChooserViewController()
//        viewController.modalPresentationStyle = .formSheet
//        self.present(viewController, animated: true) {
//        }
    }

    @objc func togglePreferencesPopover(_ sender: Any?) {
//        let viewController = PreferencesViewController()
//        viewController.modalPresentationStyle = .formSheet
//        self.present(viewController, animated: true) {
//        }
    }

    @objc func showShareSheet(_ sender: Any?) {

//        if let url = URL(string: "https://istweb.apple.com/rooster") {
//            
//            let shareSheet = UIActivityViewController(activityItems: [ "Rooster App:", url ],
//                                                      applicationActivities: nil)
//            
//            shareSheet.excludedActivityTypes = [
//                .postToFacebook,
//                .postToTwitter,
//                .postToWeibo,
//                .assignToContact,
//                .saveToCameraRoll,
//                .postToFlickr,
//                .postToVimeo,
//                .postToTencentWeibo,
//                .openInIBooks,
//                .markupAsPDF]
//            
//            shareSheet.modalPresentationStyle = .fullScreen
//            
//            self.present(shareSheet, animated: true) {
//            }
//        }
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
        item.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "calender")
        item.label = "CALENDARS".localized
        item.action = #selector(toggleCalendarsPopover(_:))
        item.target = self
        item.isEnabled = false
        return item
    }()
    
    lazy var preferencesToolbarItem: NSToolbarItem = {
        let item = NSToolbarItem(itemIdentifier: .preferences)
        
        let image = NSImage(systemSymbolName:  "gearshape", accessibilityDescription: "gearshape")
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
        item.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: "sharing")
        item.isEnabled = false
//        item.activityItemsConfiguration = self
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
    
    
}

extension NSToolbarItem.Identifier {
    static let share = NSToolbarItem.Identifier("com.apple.commapps.rooster.share")
    static let preferences = NSToolbarItem.Identifier("com.apple.commapps.rooster.preferences")
    static let calendars = NSToolbarItem.Identifier("com.apple.commapps.rooster.showCalendars")
}
