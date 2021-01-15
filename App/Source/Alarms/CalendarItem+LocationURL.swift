//
//  CalendarItem+LocationURL.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/15/21.
//

import Foundation

extension CalendarItem {
    
    func openLocationURL() {
        if let url = self.knownLocationURL {
            AppDelegate.instance.appKitPlugin.utilities.openLocationURL(url) { (success, error) in
                self.logger.log("Opened URL: \(url). Success: \(success), error: \(error != nil ? error!.localizedDescription : "nil")")
            }
        } else {
            self.logger.log("No location url found")
        }
    }

    func bringLocationAppsToFront() {
        if let url = self.knownLocationURL {
            AppDelegate.instance.appKitPlugin.utilities.bringLocationAppsToFront(for: url)
        } else {
            self.logger.log("No location url found")
        }
    }
    
    var knownLocationURL: URL? {
        return self.findURL(containing: "appleinc.webex.com/appleinc")
    }
}
