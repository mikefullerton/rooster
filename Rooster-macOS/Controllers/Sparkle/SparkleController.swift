//
//  SparkleSupport.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

import Foundation
import RoosterCore
import Sparkle

#if targetEnvironment(macCatalyst)

#else
protocol AppKitInstallationUpdater {}
#endif

public class SparkleController : NSObject, Loggable, SparkleTimerDelegate {
    
    public var state = State([]) {
        didSet {
            self.didUpdateState(oldValue, self.state)
        }
    }
    
    public var canCheckForUpdates: Bool {
        return self.state.isEmpty
    }
    
    var progressWindow: SparkleProgressWindowController?

    func showProgressWindow() -> SparkleProgressWindowController {
        if self.progressWindow == nil {
            self.progressWindow = SparkleProgressWindowController()
            self.progressWindow?.showWindow(self)
        }
        
        return self.progressWindow!
    }
    
    func hideProgressWindow() {
        self.progressWindow?.close()
        self.progressWindow = nil
    }

    
    var infoWindow: SparkleInformationWindowController?

    func showInfoWindow() -> SparkleInformationWindowController {
        if self.infoWindow == nil {
            self.infoWindow = SparkleInformationWindowController()
            self.infoWindow?.showWindow(self)
        }
        
        return self.infoWindow!
    }
    
    func hideInfoWindow() {
        self.infoWindow?.close()
        self.infoWindow = nil
    }
    
    
    public private(set) var updater: SPUUpdater? = nil
    public var error: Error?
    public private(set) lazy var timer = SparkleTimer(withDelegate: self)

    override public init() {
        super.init()
        self.state.controller = ControllerReference(withSparkleController: self)
        self.state = .initializing
    }
    
    @objc func appDidBecomeActiveNotification(_ sender: Notification) {
        self.checkForUpdatesIfNeeded()
    }
    
    public func sparkleTimerCheckForUpdates(_ timer: SparkleTimer) {
        self.checkForUpdatesIfNeeded()
    }

    public func configure(withAppBundle appBundle: Bundle) {
        
        let updater = SPUUpdater(hostBundle: appBundle,
                                 applicationBundle: appBundle,
                                 userDriver: self,
                                 delegate: self)

        updater.sendsSystemProfile = false
        updater.automaticallyChecksForUpdates = false // this updates its check date if it fails. Dumb.
        updater.automaticallyDownloadsUpdates = true
        
        do {
            try updater.start()
            
        } catch let error {
            self.logger.error("Failed to start with error: \(error.localizedDescription)")

            self.state = .failed
            // TODO: put up alert.
            
            return
        }
        
        self.updater = updater
        self.state = []
        
        self.logger.log("Updater configured. Last update check was: \(self.timer.lastUpdateCheckDate?.description ?? "None" )")
        
        self.checkForUpdatesIfNeeded()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActiveNotification(_:)),
                                               name: NSApplication.didBecomeActiveNotification, object: nil)
    }
    
    public func checkForUpdates() {
        self.logger.log("User requested update check")

        if self.state.contains( .checking ) {
            self.logger.log("Already checking")
            
            if !self.state.contains( .userInitiated ) {
                self.state += .userInitiated
            }
            
            return
        }

        self.state += [ .checking, .userInitiated ]
        
        self.showProgressWindow().showCheckingForUpdates()

        self.timer.stop()
        if let updater = self.updater {
            updater.checkForUpdates()
        }
    }
    
    
    func checkForUpdatesIfNeeded() {
        
        if self.state.contains( .checking ) {
            self.logger.log("Already checking")
            return
        }
        
        self.timer.stop()
        self.logger.log("Starting to check if check for new update is needed")
        self.state += .checking
        
        DispatchQueue.main.async {
            if let updater = self.updater {
                if self.timer.isTimeForUpdate {
                    self.logger.log("Starting check for updates in the backgound on feed: \(updater.feedURL)")
                    updater.checkForUpdatesInBackground()
                } else {
                    
                    self.state -= .checking
                    
                    self.logger.log("Not checking for updates yet")
                    self.timer.startNextCheckTimer()
                }
            }
        }
    }
    
    func didUpdateState(_ oldState: State, _ newState: State) {
        self.logger.log("State changed from: \(oldState.description), to: \(newState.description)")

//        if oldState.contains(.checking) && !newState.contains(.checking) {
//            self.currentWindow = nil
//        }
//        
//        if newState.contains( [.checking, .userInitiated ]) {
//            self.currentWindow = CheckingForUpdatesWindow()
//        }
        
    }
}




