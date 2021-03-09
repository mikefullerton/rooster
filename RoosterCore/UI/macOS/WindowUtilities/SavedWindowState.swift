//
//  SavedWindowState.swift
//  Rooster
//
//  Created by Mike Fullerton on 4/21/21.
//

import Cocoa
import Foundation

public struct SavedWindowState: Codable, Equatable, Loggable, CustomStringConvertible {
    public let windowFrame: CGRect
    public let screenFrame: CGRect
    public let screenName: String
    public let isVisible: Bool

    public init(windowContentRect: CGRect,
                screenFrame: CGRect,
                screenName: String,
                isVisible: Bool) {
        self.windowFrame = windowContentRect
        self.screenFrame = screenFrame
        self.screenName = screenName
        self.isVisible = isVisible
    }

    public init?(forWindow window: NSWindow) {
        guard let screen = window.screen else {
            Self.logger.error("Screen is nil")
            return nil
        }

        self.windowFrame = window.frame
        self.screenFrame = screen.frame
        self.screenName = screen.localizedName
        self.isVisible = window.isVisible
    }

    public func save(withAutoSaveKey autoSaveKey: String) -> Bool {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            let json = String(data: jsonData, encoding: .utf8)
            UserDefaults.standard.set(json, forKey: autoSaveKey)
            UserDefaults.standard.synchronize()
            return true
        } catch {
            self.logger.error("Failed to encode json for: \(self.description)")
        }

        return false
    }

    public static func save(window: NSWindow, autoSaveKey: String) -> Bool {
        guard let encodedState = SavedWindowState(forWindow: window) else {
            self.logger.error("Failed to create saved state")
            return false
        }

        guard encodedState.save(withAutoSaveKey: autoSaveKey) else {
            self.logger.error("Saved window state for \(window.title): \(encodedState.description) failed")
            return false
        }

        self.logger.log("Saved window state for \(window.title): \(encodedState.description)")
        return true
    }

    public static func read(withAutoSaveKey autoSaveKey: String) -> SavedWindowState? {
        guard let savedString = UserDefaults.standard.value(forKey: autoSaveKey) as? String else {
            return nil
        }

        guard let jsonData = savedString.data(using: .utf8) else {
            self.logger.error("Failed to convert string to data: \(savedString)")
            return nil
        }

        do {
            let jsonDecoder = JSONDecoder()
            let state = try jsonDecoder.decode(SavedWindowState.self, from: jsonData)
            self.logger.debug("Read saved state: \(state.description)")
            return state
        } catch {
            self.logger.error("Failed to decode json: \(savedString)")
        }

        return nil
    }

    public var screen: NSScreen? {
        if let index = NSScreen.screens.firstIndex(where: { $0.localizedName == self.screenName }) {
            return NSScreen.screens[index]
        }

        return nil
    }

    public var isScreenUnchanged: Bool {
        if let index = NSScreen.screens.firstIndex(where: { $0.localizedName == self.screenName }) {
            let screen = NSScreen.screens[index]

            guard screen.frame == self.screenFrame else {
                self.logger.warning("Screen frame did change: was: \(String(describing: self.screenFrame)), now: \(String(describing: screen.frame))")
                return false
            }

            return true
        } else {
            self.logger.warning("Screen not found: \(self.screenName) in \(NSScreen.screens.map { $0.localizedName }.joined(separator: ","))")
        }

        return false
    }

    public var description: String {
        """
        \(type(of: self)): \
        windowContentRect: \(String(describing: self.windowFrame)), \
        screenFrame: \(String(describing: self.screenFrame)), \
        screenName: \(self.screenName), \
        isVisible: \(String(describing: self.isVisible))
        """
    }
}

extension NSWindowController {
    public func saveState(withAutoSaveKey autoSaveKey: AutoSaveKey) -> Bool {
        guard let window = self.window else {
            return false
        }
        return SavedWindowState.save(window: window, autoSaveKey: autoSaveKey.key)
    }

    public func restoreState(withAutoSaveKey autoSaveKey: AutoSaveKey, initialSize: CGSize) -> Bool {
        guard let window = self.window else {
            return false
        }

        guard let savedState = SavedWindowState.read(withAutoSaveKey: autoSaveKey.key) else {
            return false
        }

        guard savedState.isScreenUnchanged else {
            return false
        }

        guard let screen = savedState.screen else {
            return false
        }

        let updateVisible = window.isVisible && savedState.isVisible

        var frame = savedState.windowFrame

        if initialSize != CGSize.zero {
            frame = window.frameRect(forContentRect: CGRect(origin: CGPoint.zero,
                                                            size: initialSize))

            frame.origin.x = savedState.windowFrame.origin.x
            frame.origin.y = savedState.windowFrame.maxY - frame.size.height

            frame = frame.constrainHeightVerticallyFlipped(inContainingRect: screen.frame)
        }

        window.setFrame(frame,
                        display: updateVisible,
                        animate: updateVisible)

        if savedState.isVisible || autoSaveKey.alwaysShow {
            self.showWindow(self)
        } else {
            self.close()
        }

        return true
    }
}
