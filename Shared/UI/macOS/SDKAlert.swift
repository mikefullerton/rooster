//
//  SDKAlert.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/26/21.
//

import Foundation
import Cocoa

struct SDKAlert {
    
    let alert: NSAlert = NSAlert()
    
    init() {
        
    }
    
    func presentOKCancel(question: String,
                         text: String,
                         style: NSAlert.Style) -> Bool {
        
        self.alert.messageText = question
        self.alert.informativeText = text
        self.alert.alertStyle = style
        self.alert.addButton(withTitle: "OK")
        self.alert.addButton(withTitle: "Cancel")
        let res = alert.runModal()
        if res == .alertFirstButtonReturn {
            return true
        }
        return false
    }
}

