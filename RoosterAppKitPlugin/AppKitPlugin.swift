//
//  AppKitPlugin.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 11/19/20.
//

import Foundation
import AppKit
import EventKit

extension Date {
    
    func isAfterDate(_ date: Date) -> Bool {
        let isAfter = self.compare(date) == .orderedDescending
        return isAfter
    }
    
    func isBeforeDate(_ date: Date) -> Bool {
        let isBefore = self.compare(date) == .orderedAscending
        return isBefore
    }
    
}


class AppKitPlugin : NSObject, AppKitPluginProtocol {
    func bringAppToFront() {
        let result = NSRunningApplication.current.activate(options: .activateIgnoringOtherApps)
        
        print("Brought app to front: \(result)")
    }
    
    func bringAnotherApp(toFront bundleIdentier: String) {
        let apps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentier)
        
        for bundle in apps {
            let result = bundle.activate(options: .activateIgnoringOtherApps)
            
            print("attempted to foreground: \(bundle): \(result)")
        }
    }
    
    func findEvents(with calendars: [EKCalendar]!, store: EKEventStore!) -> [EKEvent]! {
        let currentCalendar = NSCalendar.current
        
        let dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: Date())
        
        guard let today = currentCalendar.date(from: dateComponents) else {
            return []
        }
        
        guard let tomorrow: Date = currentCalendar.date(byAdding: .day, value: 30, to: today) else {
            return []
        }
        
        let predicate = store.predicateForEvents(withStart: today,
                                                 end: tomorrow,
                                                 calendars: calendars)

    
        let now = Date()
        
        var events:[EKEvent] = []
        
        for event in store.events(matching: predicate) {
            
            if event.isAllDay {
                continue
            }
            
            guard let endDate = event.endDate else {
                continue
            }
            
            if event.status == .canceled {
                continue
            }
            
//            guard let title = event.title else {
//                continue
//            }

            if endDate.isAfterDate(now) {
                events.append(event)
            }
        }
        
        return events
    }
    
    func requestPermissionToDelegateCalendars(for eventStore: EKEventStore, completion: ((Bool, EKEventStore?, Error?) -> Void)?) {
        if completion != nil {
            completion!(false, nil, nil)
        }
    
        let sources = eventStore.delegateSources

        let delegateEventStore = EKEventStore(sources: sources)

        delegateEventStore.requestAccess(to: EKEntityType.event) { (success, error) in

            if success == false || error != nil {
                if completion != nil {
                    completion!(false, nil, error)
                }
            } else {
                if completion != nil {
                    completion!(true, delegateEventStore, nil)
                }
            }
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
