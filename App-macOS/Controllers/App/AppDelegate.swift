//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Foundation
import Cocoa

@main
class AppDelegate: NSObject,
                   NSApplicationDelegate,
                   AppControllerAware,
                   Loggable,
                   NSWindowDelegate,
                   FirstLaunchWindowControllerDelegate {

    private let sparkleController = SparkleController()
    
    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static var instance: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    private var mainWindowController: MainWindowController?
    private var launchWindow: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.showLoadingWindow()

        self.showDeveloperMenuIfNeeded()
        
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
    
    @IBAction @objc func showHelp(_ sender: Any) {
        self.showHelp()
    }
    
    func showRadarAlert() {

        let alert: NSAlert = NSAlert()
        alert.messageText = "Would you like to file a Radar?"
        alert.informativeText = "All bugs or suggestions are welcome!"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "rdar://new/problem/componentid=1188232")!,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
    
    func showCodeAlert() {
        
        let alert: NSAlert = NSAlert()
        alert.messageText = "Would you like to get involved in Rooster's development?"
        alert.informativeText = "Pull requests are wecome! \n\n(Contact mfullerton@apple.com if you don't have web access to code)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Go To Code")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "https://stashweb.sd.apple.com/users/mfullerton/repos/rooster")!,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
    
    func showHelp() {
        if let url = self.infoUrl {
            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
    
    @IBAction @objc func fileRadar(_ sender: Any) {
        self.showRadarAlert()
    }
    
    @IBAction @objc func openRepoURL(_ sender: Any) {
        self.showCodeAlert()
    }
   
    @IBAction @objc func checkForUpdates(_ sender: Any) {
        self.sparkleController.checkForUpdates()
    }
    
    @IBAction @objc func showPreferences(_ sender: Any) {
        PreferencesWindow.show()
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
        PreferencesWindow.show()
    }
    
    func firstLaunchWindowControllerShowCalendars(_ firstLaunchWindowController: FirstLaunchWindowController) {
    }
    
    public func didAuthenticate() {
        
        self.logger.log("Application authenticate EventKit access")

        self.menuBarController.showInMenuBar()
        
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

