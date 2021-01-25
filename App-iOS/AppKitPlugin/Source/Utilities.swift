//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import AppKit

@objc class Utilities : NSObject, AppKitUtilities, Loggable {
    private var userAttentionRequest: Int = 0
    
    let webexBundleID = "com.cisco.webexmeetingsapp"
  
    //            <?xml version="1.0" encoding="UTF-8"?>
    //            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    //            <plist version="1.0">
    //            <array>
    //                <dict>
    //                    <key>CFBundleTypeRole</key>
    //                    <string>Editor</string>
    //                    <key>CFBundleURLName</key>
    //                    <string>cisco.webex.meetingsapp</string>
    //                    <key>CFBundleURLSchemes</key>
    //                    <array>
    //                        <string>wbxappmac</string>
    //                    </array>
    //                </dict>
    //            </array>
    //            </plist>


    func openURLDirectly(inAppIfPossible url: URL, completion:((_ success: Bool, _ error: Error?) -> Void)?) {

        // this doesn't work. I'm not sure it's even possible.

        if url.absoluteString.contains("webex") {

           // NSWorkspace.shared.open(url)
            https://appleinc.webex.com/meet/mfullerton
            
            if let webexURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: webexBundleID) {

                let webexURLString = url.absoluteString.replacingOccurrences(of: "https:", with: "wbxappmac:")

                if let newURL = URL(string: webexURLString) {

                    let config = NSWorkspace.OpenConfiguration()
                    config.promptsUserIfNeeded = false
                    
                    NSWorkspace.shared.open([newURL],
                                            withApplicationAt:webexURL,
                                            configuration: config) { (runningApplication, error) in
                        if completion != nil {

                            let success = runningApplication != nil ? true : false

                            completion!(success, error)
                        }
                    }
                }

            }
            
        }
    }
    
    func startBouncingAppIcon() {
        self.stopBouncingAppIcon()
        self.userAttentionRequest = NSApp.requestUserAttention(.criticalRequest)
    }
    
    func stopBouncingAppIcon() {
        if self.userAttentionRequest != 0 {
            NSApp.cancelUserAttentionRequest(self.userAttentionRequest)
            self.userAttentionRequest = 0
        }
    }
    
    func bounceAppIconOnce() {
        self.stopBouncingAppIcon()
        self.userAttentionRequest = NSApp.requestUserAttention(.informationalRequest)
//        DispatchQueue.main.async {
//            self.stopBouncingAppIcon()
//        }
    }
    
    func openNotificationSettings() {
//        let urlString = "/System/Library/PreferencePanes/Notifications.prefPane"
//        let url = URL(fileURLWithPath: urlString)
//
//        let config = NSWorkspace.OpenConfiguration()
//        config.promptsUserIfNeeded = false
//
//        NSWorkspace.shared.openApplication(at: url, configuration: config) { (results, error) in
//
//            print("\(results) : \(error)")
//        }
//
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "open", "/System/Library/PreferencePanes/Notifications.prefPane"]
        task.launch()
        task.waitUntilExit()
    }
    
    func bringAppToFront() {
        let result = NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
        
        self.logger.log("Attempted to bring app to front. Success: \(result)")
    }
    
    func findRunningApplication(for bundleIdentifier: String) -> [NSRunningApplication] {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        if apps.count > 0 {
            return apps
        }
        
        for app in NSWorkspace.shared.runningApplications {
            let name = app.localizedName ?? ""
            if let bundleID = app.bundleIdentifier {
                if bundleIdentifier == bundleID {
                    self.logger.log("Found running app: \(name), bundle identifier: \(bundleID)")
                    return [ app ]
                }
            }
        }
        
        return []
    }
    
    
    func bringAnotherApp(toFront bundleIdentifier: String,
                         completion:((_ success: Bool, _ error: Error?) -> Void)?) {
        
        self.logger.log("bringing app to front: \(bundleIdentifier)")
        
        let apps = self.findRunningApplication(for: bundleIdentifier)
        
        guard apps.count > 0 else {
            self.logger.error("did not find any apps for bundleIdentifier: \(bundleIdentifier)")
            
            if completion != nil {
                completion!(false, nil)
            }
            
            return
        }
        
        for bundle in apps {
            bundle.unhide()
            
            let result = bundle.activate(options: .activateIgnoringOtherApps)
            
            self.logger.log("attempted to foreground: \(bundle): success: \(result)")
        }
        
        if completion != nil {
            completion!(true, nil)
        }
    }
    
    func bringLocationAppsToFront(for url: URL) {
        self.bringAnotherApp(toFront: "com.apple.Safari", completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            if url.absoluteString.contains("webex") {
                self.bringAnotherApp(toFront: "com.webex.meetingmanager", completion: nil)
            }
        }
    }
    
    func didOpenURL(for url: URL, completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
        if completion != nil {
            completion!(true, nil)
        }
    }

    func openLocationURL(_ url: URL, completion: ((Bool, Error?) -> Void)? = nil) {
        let config = NSWorkspace.OpenConfiguration()
        config.promptsUserIfNeeded = false
        
        self.logger.log("opening location URL: \(url)")

        self.bringLocationAppsToFront(for: url)
        
        NSWorkspace.shared.open(url,
                                configuration: config) { [weak self] (runningApplication, error) in
            
            guard error != nil else {
                self?.logger.error("opening location URL: \(url), failed with error: \(error != nil ? error!.localizedDescription : "nil")")

                if let completionBlock = completion {
                    completionBlock(false, error)
                }
                return
            }
            self?.logger.log("opening location URL: \(url) succeed")

            self?.didOpenURL(for: url, completion: completion)
        }
    }
}
