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

    private let sparkleController = SparkleController()
    
    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static var instance: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    private var mainWindowController: MainWindowController?
    private var launchWindow: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.showLoadingWindow()
        NSApp.activate(ignoringOtherApps: true)

        self.userNotificationController.requestAccess()
        
        self.dataModelController.authenticate { (success) in
            DispatchQueue.main.async {
                self.didAuthenticate()
            }
        }
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
 
    func hideLaunchWindow() {
        if let launchWindow = self.launchWindow {
            launchWindow.close()
            self.launchWindow = nil
        }
    }
    
    func showLoadingWindow() {
        let window = LoadingWindowController()
        self.launchWindow = window
        window.showWindow(self)
    }
    
    public func showFirstRunWindow() {
        self.hideLaunchWindow()
        
        let window = FirstLaunchWindowController()
        self.launchWindow = window
        window.delegate = self
        window.showWindow(self)
    }
    
    public func showMainWindow() {
//        DispatchQueue.main.async {
            self.hideLaunchWindow()
            
            let mainWindow = MainWindowController()
            mainWindow.showWindow(self)
            
            self.mainWindowController = mainWindow
//        }
    }
     
    func firstLaunchWindowControllerShouldDismiss(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.showMainWindow()
    }
    
    func firstLaunchWindowControllerShowHelp(_ firstLaunchWindowController: FirstLaunchWindowController) {
        self.showHelp(self)
    }
    
    func firstLaunchWindowControllerShowSettings(_ firstLaunchWindowController: FirstLaunchWindowController) {
        PreferencesWindow().showWindow(self)
    }
    
    func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController) {
    }
    
    public func didAuthenticate() {
        
        self.logger.log("Application authenticate EventKit access")

        #if targetEnvironment(macCatalyst)
        self.appKitPlugin.menuBarPopover.showIconInMenuBar()
        #endif
        
//        self.sparkleController.delegate = self
        self.sparkleController.configure(withAppBundle: Bundle.init(for: type(of:self)))
        
        NotificationCenter.default.post(name: AppDelegate.CalendarDidAuthenticateEvent, object: self)
        
        var savedState = SavedState()
        if savedState.bool(forKey: .firstRunWasPresented) {
            self.showMainWindow()
        } else {
            savedState.setBool(true, forKey: .firstRunWasPresented)
            self.showFirstRunWindow()
        }
    }
}

