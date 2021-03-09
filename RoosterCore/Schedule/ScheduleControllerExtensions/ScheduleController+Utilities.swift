//
//  ScheduleController+Utilities.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/1/21.
//

import AppKit
import Foundation

extension ScheduleController {
    public func showSaveError(forScheduleItem scheduleItem: ScheduleItem,
                              informativeText: String,
                              error: Error? ) {
        let alert = NSAlert()
        alert.messageText = "Rooster encountered an error while updating your \(scheduleItem.typeDisplayName)."
        var moreInfo = error?.localizedDescription
        if moreInfo != nil && !moreInfo!.isEmpty {
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
