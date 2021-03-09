//
//  SystemHotKitController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/2/21.
//

import AppKit
import Carbon
import Foundation
import RoosterCore

public class HotKeysController {
    private var hotKeys: [HotKey]

    public init() {
        self.hotKeys = []
    }

    public func addHotKeys() {
        let hotKey = HotKey(keyCode: UInt32(kVK_ANSI_R), modifierFlags: [ .command, .option, .shift ], userData: nil)
        hotKey.register { hotKey, _, _ in
            hotKey.logger.info("hello world!")
        }

        self.addHotKey(hotKey: hotKey)
    }

    public func addHotKey(hotKey: HotKey) {
        self.hotKeys.append(hotKey)
    }

    public func hotKey(forID id: UInt32) -> HotKey? {
        if let index = self.hotKeys.firstIndex(where: { $0.id == id }) {
            return self.hotKeys[index]
        }

        return nil
    }
}
