//
//  NSEvent+CarbonFlags.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/2/21.
//

import AppKit
import Carbon
import Foundation

extension NSEvent {
    public static func carbonModifierFlags(forModifierFlags modifierFlags: NSEvent.ModifierFlags) -> UInt32 {
        let flags = UInt(modifierFlags.rawValue)
        var newFlags: Int = 0

        if (flags & NSEvent.ModifierFlags.control.rawValue) > 0 {
            newFlags |= controlKey
        }

        if (flags & NSEvent.ModifierFlags.command.rawValue) > 0 {
            newFlags |= cmdKey
        }

        if (flags & NSEvent.ModifierFlags.shift.rawValue) > 0 {
            newFlags |= shiftKey
        }

        if (flags & NSEvent.ModifierFlags.option.rawValue) > 0 {
            newFlags |= optionKey
        }

        if (flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0 {
            newFlags |= alphaLock
        }

        return UInt32(newFlags)
    }
}
