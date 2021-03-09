//
//  ReminderPreferences.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 3/26/21.
//

import Carbon
import Foundation
import RoosterCore

public struct KeyboardShortcutPreferences: Equatable, CustomStringConvertible {
    public var shortcuts: [KeyboardShortcut]

    public static let `default` = KeyboardShortcutPreferences()

    public init() {
        self.shortcuts = [
            KeyboardShortcut(id: .mainWindow, isEnabled: false, key: "t", keyCode: UInt32(kVK_ANSI_T), modifierFlags: [ .option, .control ]),
            KeyboardShortcut(id: .preferences, isEnabled: false, key: "p", keyCode: UInt32(kVK_ANSI_P), modifierFlags: [ .option, .control ]),
            KeyboardShortcut(id: .calendars, isEnabled: false, key: "c", keyCode: UInt32(kVK_ANSI_C), modifierFlags: [ .option, .control ]),
            KeyboardShortcut(id: .newReminder, isEnabled: false, key: "r", keyCode: UInt32(kVK_ANSI_R), modifierFlags: [ .option, .control ]),
            KeyboardShortcut(id: .stopAlarms, isEnabled: false, key: "⎋", keyCode: UInt32(kVK_Escape), modifierFlags: [ ])
        ]
    }

    public var description: String {
        """
        \(type(of: self)): \
        shortCuts: \(String(describing: self.shortcuts))
        """
    }
}

extension KeyboardShortcutPreferences: Codable {
    private enum CodingKeys: String, CodingKey {
        case shortcuts
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.shortcuts = try values.decodeIfPresent([KeyboardShortcut].self, forKey: .shortcuts) ?? Self.default.shortcuts
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.shortcuts, forKey: .shortcuts)
    }
}

extension KeyboardShortcut {
    public enum KeyboardShortcutID: String, RawRepresentable {
        case mainWindow
        case preferences
        case calendars
        case newReminder
        case stopAlarms
    }

    public init(id: KeyboardShortcutID,
                isEnabled: Bool,
                key: String,
                keyCode: UInt32,
                modifierFlags: NSEvent.ModifierFlags) {
        self.init(id: id.rawValue, isEnabled: isEnabled, key: key, keyCode: keyCode, modifierFlags: modifierFlags)
    }
}
