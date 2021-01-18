//
//  AppDelegate.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/18/21.
//
import Foundation
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, AppControllerAware, Loggable, NSWindowDelegate {

    @IBOutlet var window: NSWindow!

  //  private let sparkleController = SparkleController()
    
    public static let CalendarDidAuthenticateEvent = NSNotification.Name("AlarmControllerDidAuthenticateEvent")

    static var instance: AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    let mainViewController = MainViewController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.userNotificationController.requestAccess()
        
        self.dataModelController.authenticate { (success) in
            DispatchQueue.main.async {
                self.didAuthenticate()
            }
        }
        
        self.window.contentViewController = self.mainViewController
        self.mainViewController.configure()
        
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
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            NSWorkspace.shared.open(url,
                                    configuration: NSWorkspace.OpenConfiguration(),
                                    completionHandler: nil)
        }
    }
    
    @IBAction @objc private func fileRadar(_ sender: AppDelegate) {
        //        rdar://new/problem/componentid=1188232

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
//        self.sparkleController.checkForUpdates()
    }

//    func appKitInstallationUpdater(_ updater: AppKitInstallationUpdater, didCheckForUpdate updateAvailable: Bool, error: Error?) {
//
//    }
    
    public func didAuthenticate() {
        
        self.logger.log("Application authenticate EventKit access")

        #if targetEnvironment(macCatalyst)
        self.appKitPlugin.menuBarPopover.showIconInMenuBar()
        #endif
        
//        self.sparkleController.delegate = self
//        self.sparkleController.configure(withAppBundle: Bundle.init(for: type(of:self)))
        
//        FirstRunController().handleFirstRunIfNeeded()
        
        NotificationCenter.default.post(name: AppDelegate.CalendarDidAuthenticateEvent, object: self)
    }
    
    public func mainWindowDidShow() {
        self.logger.log("Main Window did show")

        self.dataModelController.authenticate { (success) in
            DispatchQueue.main.async {
                self.didAuthenticate()
            }
        }
    }

}

