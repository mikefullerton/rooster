//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Foundation
import Cocoa

class Application: NSApplication, Loggable {
    
//    override func sendEvent(_ event: NSEvent) {
//        super.sendEvent(event)
//        
//        print("global event tracking: Event: \(event)")
//    }
}

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
    
    private(set) var mainWindowController: MainWindowController?
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
        
//        NSEvent.addLocalMonitorForEvents(matching: .any) { event in
//            print("event: \(event)")
//            
//            return event
//        }
//
//        NSEvent.addGlobalMonitorForEvents(matching: .any) { event in
//            print("global event: \(event)")
//        }

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
        NSApp.activate(ignoringOtherApps: true)
        self.showRadarAlert()
    }
    
    @IBAction @objc func openRepoURL(_ sender: Any) {
        self.showCodeAlert()
    }
   
    @IBAction @objc func checkForUpdates(_ sender: Any) {
        self.sparkleController.checkForUpdates()
    }
    
    @IBAction @objc func showPreferences(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindow.show()
    }
    
    @IBAction @objc func stopAllAlarms(_ sender: Any) {
        self.alarmNotificationController.handleUserClickedStopAll()
    }

    @IBAction @objc func bringAppToFront(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction @objc func quitRooster(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    @IBAction @objc func eventListWasClicked(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
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

