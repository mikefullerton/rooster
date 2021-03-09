//
//  KeyUpEventTextField.swift
//  Rooster-iOS
//
//  Created by Mike Fullerton on 4/25/21.
//

import Cocoa
import Foundation

public protocol KeyUpEventTextFieldDelegate: NSTextFieldDelegate {
    func textField(_ textField: NSTextField, keyUpEvent: NSEvent)
}

public class KeyUpEventTextField: SizedTextField {
    override public func keyUp(with event: NSEvent) {
        super.keyUp(with: event)

        if let delegate = self.delegate as? KeyUpEventTextFieldDelegate {
            delegate.textField(self, keyUpEvent: event)
        }
    }
}
