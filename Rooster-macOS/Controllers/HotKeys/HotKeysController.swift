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

public class HotKeysController: Loggable {
    private var hotKeys: [HotKey]

    public var isEnabled = true

    public init() {
        self.hotKeys = []
    }

    public func setKeyboadShortcuts(
        _ keyboardShortcuts: [(shortcut: KeyboardShortcut, handler: (_ KeyboardShortcut: KeyboardShortcut) -> Void)]) -> [KeyboardShortcut] {
        self.removeAll()

        var shortCuts: [KeyboardShortcut] = []

        keyboardShortcuts.forEach { shortcut in
            if let hotKey = shortcut.shortcut.hotKey {
                self.hotKeys.append(hotKey)

                let error = hotKey.register { [weak self] _, _, _ in
                    guard let self = self else { return }

                    if self.isEnabled && shortcut.shortcut.isEnabled {
                        self.logger.info("Invoking hotkey: \(shortcut.shortcut.description)")
                        shortcut.handler(shortcut.shortcut)
                    }
                }

                if let error = error {
                    self.logger.error("registering hotkey failed: \(shortcut.shortcut.description) with error: \(error)")

                    var failed = shortcut.shortcut
                    failed.error = error

                    shortCuts.append(failed)
                } else {
                    self.logger.log("registering hotkey succeeded: \(shortcut.shortcut.description)")

                    shortCuts.append(shortcut.shortcut)
                }
            }
        }

        return shortCuts
    }

    public func removeAll() {
        self.hotKeys.forEach { $0.unregister() }
        self.hotKeys = []
    }

    public func hotKey(forID id: UInt32) -> HotKey? {
        if let index = self.hotKeys.firstIndex(where: { $0.id == id }) {
            return self.hotKeys[index]
        }

        return nil
    }
}

extension KeyboardShortcut {
    var hotKey: HotKey? {
        guard self.key.count == 1 else {
            return nil
        }

        return HotKey(keyCode: self.keyCode,
                      modifierFlags: self.modifierFlags,
                      userData: nil)
    }
}
