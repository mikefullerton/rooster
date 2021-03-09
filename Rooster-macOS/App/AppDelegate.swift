//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Foundation
import RoosterCore
import Cocoa

class Application: NSApplication, Loggable {
    
//    override func sendEvent(_ event: NSEvent) {
//        super.sendEvent(event)
//        
//        print("global event tracking: RCEvent: \(event)")
//    }
}

@main
class AppDelegate: NSObject,
                   NSApplicationDelegate,
                   Loggable,
                   NSWindowDelegate,
                   FirstLaunchWindowControllerDelegate,
                   NSUserInterfaceValidations,
                    DataModelAware {
    

    public static let ApplicationStateVersion = 8
    
    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")
    public static let ResetApplicationState = Notification.Name("ResetApplicationState")
    
    static var instance: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    private(set) var mainWindowController: MainWindowController?
    private var launchWindow: NSWindowController?
    
    private var dataModelReloader = DataModelReloader()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.showLoadingWindow()

        self.dataModelReloader.target = self
        
        var resetAppState = false
        
        if SavedState().int(forKey: .applicationStateVersion) != Self.ApplicationStateVersion {
            resetAppState = true
        }
        
        if NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask) == .option {
            resetAppState = true
        }
        
        SoundFolder.startLoadingDefaultSoundFolder()
        
        Controllers.userNotificationController.requestAccess()
        
        Controllers.dataModelController.readFromStorage() { success, error in
        
            if !success {
                var savedState = SavedState()
                savedState.setBool(false, forKey: .lookedForCalendarOnFirstRun)
                    
                self.showDataModelErrorAlert(error)
            }
            
            
            Controllers.dataModelController.requestAccessToCalendars { (success, error) in
                
                if !success {
                    self.showUnableToAuthenticateError(error)
                }
                
                self.didAuthenticate(resetAppState: resetAppState)
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
    
    func showDataModelErrorAlert(_ error: Error?) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Rooster encountered an error reading saved data."
        var moreInfo = error?.localizedDescription
        if moreInfo != nil && moreInfo!.count > 0 {
            moreInfo = "\n\nMore Info:\n\(moreInfo!)"
        }

        alert.informativeText = "Calendar subscriptions were reset.\(moreInfo ?? "")"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        if alert.runModal() == .alertFirstButtonReturn {
        }
    }

    func showUnableToAuthenticateError(_ error: Error?) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Rooster was unable to gain access to your Calendars and Reminders."
        
        var moreInfo = error?.localizedDescription
        if moreInfo != nil && moreInfo!.count > 0 {
            moreInfo = "\n\nMore Info:\n\(moreInfo!)"
        }
        
        alert.informativeText = "You can fix this by allowing Rooster access to your Calendars and Reminders in the Security and Privacy System Preference Panel. The settings are in the Calendars and Reminders sections.\(moreInfo ?? "")"
        
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit")
        if alert.runModal() == .alertFirstButtonReturn {
            self.quitRooster(self)
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
        NSApp.activate(ignoringOtherApps: true)
        self.showRadarAlert()
    }
    
    @IBAction @objc func openRepoURL(_ sender: Any) {
        self.showCodeAlert()
    }
   
    @IBAction @objc func checkForUpdates(_ sender: Any) {
        Controllers.sparkleController.checkForUpdates()
    }
    
    @IBAction @objc func showPreferences(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindow.show()
    }
    
    @IBAction @objc func showCalendars(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
//        CalendarWindow.show()
        
        CalendarChooserViewController().presentInModalWindow(fromWindow: self.mainWindowController?.window)
   
    }
    
    @IBAction @objc func stopAllAlarms(_ sender: Any) {
        Controllers.alarmNotificationController.handleUserClickedStopAll()
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

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        let action = item.action
        
        if action == #selector(checkForUpdates(_:)) {
            return Controllers.sparkleController.canCheckForUpdates
        }

        return true
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
    
    public func didAuthenticate(resetAppState: Bool) {
        
        self.logger.log("Application authenticate EventKit access")
        
        if  resetAppState {
            self.resetAppLaunchState()
        }

        self.showDeveloperMenuIfNeeded()

        Controllers.setupControllers()
        
        NotificationCenter.default.post(name: AppDelegate.CalendarDidAuthenticateEvent, object: self)
        
        self.showMainWindow()

// TODO: This is buggy, so work out something beter in the future
//        var savedState = SavedState()
//        if savedState.bool(forKey: .firstRunWasPresented) {
//            self.showMainWindow()
//        } else {
//            savedState.setBool(true, forKey: .firstRunWasPresented)
//            self.showFirstRunWindow()
//        }
    }
    
    func resetAppLaunchState() {
        Controllers.preferencesController.delete()
        Controllers.dataModelController.dataModelStorage.deleteStoredDataModel()
        
        let dictionaryRepresentation = UserDefaults.standard.dictionaryRepresentation()
        
        for key in dictionaryRepresentation.keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
        
        var savedState = SavedState()
        savedState.setInt(Self.ApplicationStateVersion, forKey: .applicationStateVersion)
        
        NotificationCenter.default.post(name: AppDelegate.ResetApplicationState, object: self)
        
        self.logger.log("Reset application state")
    }
    
    
    func dataModelDidReload(_ dataModel: RCCalendarDataModel) {
        var savedState = SavedState()
        if !savedState.bool(forKey: .lookedForCalendarOnFirstRun) {
            savedState.setBool(true, forKey: .lookedForCalendarOnFirstRun)
            
            Controllers.dataModelController.enableAllPersonalCalendars()
            self.logger.log("enabled all personal calendars")
        }
    }
    
}

