//
//  AbstractCalendarController.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/22/21.
//

import Foundation
import EventKit
import AppKit

open class AbstractCalendarController: Loggable {
 
    
    public func showSaveError(forItem calendarItem: RCAbstractCalendarItem,
                              informativeText: String,
                              error: Error? ) {
        
        let alert: NSAlert = NSAlert()
        alert.messageText = "Rooster encountered an error while updating your \(calendarItem.typeDisplayName)."
        var moreInfo = error?.localizedDescription
        if moreInfo != nil && moreInfo!.count > 0 {
            moreInfo = "\n\nError Info:\n\(moreInfo!)"
        }

        alert.informativeText = "\(informativeText)\(moreInfo ?? "")"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        
        self.logger.error("\(alert.messageText)\(alert.informativeText)")

        if alert.runModal() == .alertFirstButtonReturn {
        }
    }
    

}
