//
//  ErrorController.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/14/21.
//

import Foundation

public class ErrorController {
    public func showDataModelErrorAlert(_ error: Error?) {
        let alert = NSAlert()
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

    public func showUnableToAuthenticateError(_ error: Error?) {
        let alert = NSAlert()
        #if REMINDERS
        alert.messageText = "Rooster was unable to gain access to your Calendars and Reminders."
        #else
        alert.messageText = "Rooster was unable to gain access to your Calendars."
        #endif

        var moreInfo = error?.localizedDescription
        if moreInfo != nil && !moreInfo!.isEmpty {
            moreInfo = "\n\nMore Info:\n\(moreInfo!)"
        }

        alert.informativeText = """
            You can fix this by allowing Rooster access to your \
            Calendars and Reminders in the Security and Privacy System Preference Panel. \
            The settings are in the Calendars and Reminders sections.\(moreInfo ?? "")
            """

        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit")
        if alert.runModal() == .alertFirstButtonReturn {
            AppControllers.shared.quitRooster()
        }
    }
}
