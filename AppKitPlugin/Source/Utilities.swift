//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import AppKit
import OSLog

@objc class Utilities : NSObject, AppKitUtilities {
    
    private let logger = Logger(subsystem: "com.apple.rooster", category: "AppKitPlugin.Utilities")
        
    func bringAppToFront() {
        let result = NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
        
        self.logger.log("Brought app to front: \(result)")
    }
    
    func bringAnotherApp(toFront bundleIdentier: String) {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentier)
        
        for bundle in apps {
            let result = bundle.activate(options: .activateIgnoringOtherApps)
            
            self.logger.log("attempted to foreground: \(bundle): \(result)")
        }
    }
    

    
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
}
