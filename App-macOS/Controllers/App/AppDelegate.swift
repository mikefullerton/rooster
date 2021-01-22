//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Foundation
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, AppControllerAware, Loggable, NSWindowDelegate, FirstLaunchWindowControllerDelegate {

//    @IBOutlet var window: NSWindow!

    private let sparkleController = SparkleController()
    
    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static var instance: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    private var loadingWindow: LoadingViewController?
    private var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.userNotificationController.requestAccess()
        
        self.dataModelController.authenticate { (success) in
            DispatchQueue.main.async {
                self.didAuthenticate()
            }
        }
        
        let loadingWindow = LoadingViewController(windowNibName: "LoadingViewController")
        self.loadingWindow = loadingWindow
        
//        loadingWindow.window?.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.runModal(for: loadingWindow.window!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    private lazy var infoUrl: URL? = {
        if  let resourcePath = Bundle.main.resourceURL {
            return resourcePath.appendingPathComponent("About/about.html")
        }
        
        return nil
    }()
    
    @IBAction @objc func showHelp(_ sender: Any?) {
        if let url = self.infoUrl {
            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
    
    @IBAction @objc private func fileRadar(_ sender: AppDelegate) {
        NSWorkspace.shared.open(URL(string: "rdar://new/problem/componentid=1188232")!,
                                configuration: NSWorkspace.OpenConfiguration(),
                                completionHandler: nil)

    }
    
    @IBAction @objc private func openRepoURL(_ sender: AppDelegate) {
        NSWorkspace.shared.open(URL(string: "https://stashweb.sd.apple.com/users/mfullerton/repos/rooster")!,
                                configuration: NSWorkspace.OpenConfiguration(),
                                completionHandler: nil)
    }
   
    @IBAction @objc private func checkForUpdates(_ sender: AppDelegate) {
        self.sparkleController.checkForUpdates()
    }

//    func appKitInstallationUpdater(_ updater: AppKitInstallationUpdater, didCheckForUpdate updateAvailable: Bool, error: Error?) {
//
//    }
    
    private var firstRunWindow: FirstLaunchWindowController?
    
    public func showFirstRunWindow() {
        let firstRun = FirstLaunchWindowController(windowNibName: "FirstLaunchWindowController")
        firstRun.delegate = self
        NSApp.runModal(for: firstRun.window!)
        
        firstRun.window?.orderOut(self)
    }
    
    public func showMainWindow() {
        
        DispatchQueue.main.async {
            let mainWindow = MainWindowController(windowNibName: "MainWindowController")
            mainWindow.window?.makeKeyAndOrderFront(self)
            
            self.mainWindowController = mainWindow
        }
    }
     
    func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController) {
        NSApp.stopModal(withCode: .OK)
        self.showMainWindow()
    }
    
    func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.showHelp(self)
    }
    
    func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController) {
        let windowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        NSApp.runModal(for: windowController.window!)
    }
    
    func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController) {
        let windowController = CalendarsWindowController(windowNibName: "CalendarsWindowController")
        NSApp.runModal(for: windowController.window!)

    }
    
    public func didAuthenticate() {
        
        self.logger.log("Application authenticate EventKit access")

        #if targetEnvironment(macCatalyst)
        self.appKitPlugin.menuBarPopover.showIconInMenuBar()
        #endif
        
//        self.sparkleController.delegate = self
        self.sparkleController.configure(withAppBundle: Bundle.init(for: type(of:self)))
        
        NotificationCenter.default.post(name: AppDelegate.CalendarDidAuthenticateEvent, object: self)
        
        NSApp.stopModal()
        self.loadingWindow?.window?.orderOut(self)
        self.loadingWindow = nil
        
        var savedState = SavedState()
        if savedState.bool(forKey: .firstRunWasPresented) {
            self.showMainWindow()
        } else {
            savedState.setBool(true, forKey: .firstRunWasPresented)
            self.showFirstRunWindow()
        }
    }
}

