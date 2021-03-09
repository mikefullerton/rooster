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
    

    public static let ApplicationStateVersion = 10
    
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
        
        self.beginLoadingStoredData {
            self.didFinishLoading(resetAppState: resetAppState)
        }
    }
    
    func showDataModelErrorAlert(_ error: Error?) {
        let alert: NSAlert = NSAlert()
        alert.messageText = "Rooster encountered an error reading saved data."
        var moreInfo = error?.localizedDescription
        if moreInfo != nil && !moreInfo!.isEmpty {
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
        if moreInfo != nil && !moreInfo!.isEmpty {
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
    
    @IBAction func showHelp(_ sender: Any) {
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
    
    @IBAction func fileRadar(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        self.showRadarAlert()
    }
    
    @IBAction func openRepoURL(_ sender: Any) {
        self.showCodeAlert()
    }
   
    @IBAction func checkForUpdates(_ sender: Any) {
        Controllers.sparkleController.checkForUpdates()
    }
    
    @IBAction func showPreferences(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
        PreferencesWindow.show()
    }
    
    @IBAction func showCalendars(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
//        CalendarWindow.show()
        
        CalendarChooserViewController().presentInModalWindow(fromWindow: self.mainWindowController?.window)
   
    }
    
    @IBAction func stopAllAlarms(_ sender: Any) {
        Controllers.alarmNotificationController.handleUserClickedStopAll()
    }

    @IBAction func bringAppToFront(_ sender: Any) {
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func quitRooster(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    @IBAction func eventListWasClicked(_ sender: Any) {
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
    
    public func dataModelDidOpen() {
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)
        self.showMainWindow()
    }
    
    public func beginLoadingStoredData(completion: @escaping () -> Void) {
        
        var errorQueue:[() -> Void] = []
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        dispatchGroup.enter()
        
        Controllers.userNotificationController.requestAccess { [weak self] (success, error) in
            
            if success {
                self?.logger.log("granted access to user notifications ok")
            } else {
                self?.logger.error("Error requesting user notification access: \(error?.localizedDescription ?? "nil")")
            }
            
            dispatchGroup.leave()
        }
        
        SoundFolder.startLoadingDefaultSoundFolder { [weak self] (success, _, error) in
            
            if success {
                self?.logger.log("Load sound folder ok")
            } else {
                self?.logger.error("Failed to load sound folder with error: \(error?.localizedDescription ?? "nil")")
            }
        
            Controllers.preferences.readFromStorage { [weak self] (success, error) in
                
                if success {
                    self?.logger.log("Loaded Preferences ok")
                } else {
                    self?.logger.error("Failed to load preferences with error: \(error?.localizedDescription ?? "nil")")
                }
                
                dispatchGroup.leave()
            }
            
            dispatchGroup.leave()
        }
    
        Controllers.dataModel.readFromStorage { [weak self] (success, error)  in
        
            if success {
                self?.logger.log("Loaded DataModel ok")
            } else {
                self?.logger.error("Failed to load DataModel with error: \(error?.localizedDescription ?? "nil")")

                errorQueue.append({
                
                    var savedState = SavedState()
                    savedState.setBool(false, forKey: .lookedForCalendarOnFirstRun)
                    
                    self?.showDataModelErrorAlert(error)
                })
            }

            dispatchGroup.leave()
        }
        
        Controllers.dataModel.requestAccessToCalendars { [weak self] (success, error) in
            if success {
                self?.logger.log("authenticated ok")
            } else {
                self?.logger.error("Failed to authenticate with error: \(error?.localizedDescription ?? "nil")")
                
                if !success {
                    errorQueue.append({
                        self?.showUnableToAuthenticateError(error)
                    })
                }
            }
        
            dispatchGroup.leave()
        }
    
        dispatchGroup.notify(queue: DispatchQueue.main) {
            
            errorQueue.forEach { $0() }
            
            completion()
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
    
    public func didFinishLoading(resetAppState: Bool) {
        
        self.logger.log("Application authenticate EventKit access")
        
        if  resetAppState {
            self.resetAppLaunchState()
        }

        self.showDeveloperMenuIfNeeded()

        Controllers.setupControllers()
        
        Controllers.eventKitController.openDataModel(withSettings:Controllers.preferences.dataModel) { [weak self] _ in
            self?.dataModelDidOpen()
        }

        
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
        Controllers.preferences.delete()
        Controllers.dataModel.dataModelStorage.deleteStoredDataModel()
        
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
            
            Controllers.dataModel.enableAllPersonalCalendars()
            self.logger.log("enabled all personal calendars")
        }
    }
    
    @objc func preferencesDidChange(_ sender: Any) {
        let dataModelPrefs = Controllers.preferences.dataModel
        
        let eventKitSettings = Controllers.eventKitController.settings
        
        if dataModelPrefs != eventKitSettings {
            Controllers.eventKitController.settings = dataModelPrefs
        }
        
        GlobalSoundVolume.volume = Controllers.preferences.soundPreferences.volume
    }
    
    
}

