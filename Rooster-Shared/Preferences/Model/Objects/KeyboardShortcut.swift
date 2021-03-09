//
//  KeyboardShortcut.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/20/21.
//

import Foundation
import RoosterCore

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public struct KeyboardShortcut: Equatable, CustomStringConvertible, Identifiable {
    public typealias ID = String
    public let id: String
    public private(set) var keyCode: UInt32
    public private(set) var key: String
    public private(set) var modifierFlags: NSEvent.ModifierFlags
    public var isEnabled: Bool
    public var error: Int

    public init() {
        self.init(id: "", isEnabled: false, key: "", keyCode: 0, modifierFlags: [])
    }

    public init(id: String,
                isEnabled: Bool,
                key: String,
                keyCode: UInt32,
                modifierFlags: NSEvent.ModifierFlags) {
        self.id = id
        self.isEnabled = isEnabled
        self.key = key
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
        self.error = 0
    }

    public var isEmpty: Bool {
        self.keyCode != 0 || self.modifierFlags.isEmpty
    }

    public var description: String {
        """
        \(type(of: self)): \
        id: \(self.id), \
        isEnabled: \(self.isEnabled), \
        modifierKeys: \(String(describing: self.modifierFlags)), \
        key: \(self.key), \
        keyCode: \(self.keyCode), \
        error: \(self.error)
        """
    }

    public mutating func set(key: String,
                             keyCode: UInt32,
                             modifierFlags: NSEvent.ModifierFlags) {
        self.key = key
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
        self.error = 0
    }
}

extension KeyboardShortcut: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case key
        case keyCode
        case modifierFlags
        case isEnabled
        case error
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.key = try values.decodeIfPresent(String.self, forKey: .key) ?? ""
        self.keyCode = try values.decodeIfPresent(UInt32.self, forKey: .keyCode) ?? 0
        self.isEnabled = try values.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        self.error = try values.decodeIfPresent(Int.self, forKey: .error) ?? 0

        if let flags = try values.decodeIfPresent(UInt.self, forKey: .modifierFlags) {
            self.modifierFlags = NSEvent.ModifierFlags(rawValue: flags)
        } else {
            self.modifierFlags = []
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.isEnabled, forKey: .isEnabled)
        try container.encode(self.keyCode, forKey: .keyCode)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.modifierFlags.rawValue, forKey: .modifierFlags)
        try container.encode(self.error, forKey: .error)
    }
}
