//
//  RCCalendarItem+LocationURL.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation

extension RCCalendarItem {
    
    public func openLocationURL() {
        if let url = self.knownLocationURL {
            
            #if os(macOS)
            Controllers.systemUtilities.openLocationURL(url) { (success, error) in
                self.logger.log("Opened URL: \(url). Success: \(success), error: \(error != nil ? error!.localizedDescription : "nil")")
            }
            #endif

            #if targetEnvironment(macCatalyst)
            Controllers.appKitPlugin.utilities.openLocationURL(url) { (success, error) in
                self.logger.log("Opened URL: \(url). Success: \(success), error: \(error != nil ? error!.localizedDescription : "nil")")
            }
            #endif
        } else {
            self.logger.log("No location url found")
        }
    }

    public func bringLocationAppsToFront() {
        if let url = self.knownLocationURL {
            #if os(macOS)
            Controllers.systemUtilities.bringLocationAppsToFront(for: url)
            #endif

            #if targetEnvironment(macCatalyst)
            Controllers.appKitPlugin.utilities.bringLocationAppsToFront(for: url)
            #endif
            
        } else {
            self.logger.log("No location url found")
        }
    }
    
    public var knownLocationURL: URL? {
        if let url = self.findURL(containing: "appleinc.webex.com/appleinc") {
            return url
        }
        
        if let url = self.findURL(containing: "appleinc.webex.com/meet") {
            return url
        }
        
        return nil
    }
}
