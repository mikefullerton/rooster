//
//  HotKey.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 4/2/21.
//

import AppKit
import Carbon
import Foundation
import RoosterCore

public class HotKey: Loggable, CustomStringConvertible, Identifiable {
    public typealias ID = UInt32

    public typealias Callback = (_ hotKey: HotKey, _ inEvent: NSEvent?, _ inUserData: AnyObject?) -> Void

    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID: EventHotKeyID
    private var keyCode: UInt32
    private var modifierFlags: NSEvent.ModifierFlags
    private var callback: Callback?
    private var eventHandlerBlock: EventHandlerUPP?
    private var eventHandlerRef: EventHandlerRef?
    private let userData: AnyObject?

    public var id: UInt32 {
        self.hotKeyID.id
    }

    public init(keyCode: UInt32, modifierFlags: NSEvent.ModifierFlags, userData: AnyObject?) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags

//        UInt32(kVK_ANSI_R)
        self.hotKeyID = EventHotKeyID()
        self.hotKeyID.id = UInt32(keyCode)

        // Not sure what "swat" vs "htk1" do.
        self.hotKeyID.signature = OSType("swat".fourCharCodeValue)
        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)

        self.userData = userData
    }

    deinit {
        self.unregister()
    }

    public func unregister() {
        if let eventHandlerRef = self.eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerBlock = nil
        }

        if let hotKeyRef = self.hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)

            self.hotKeyRef = nil
            self.callback = nil
        }
    }

    private func invoke(_ event: NSEvent?, _ userData: AnyObject?) {
        self.logger.log("Got event: \(event?.description ?? "nil"), userData: \(String(describing: userData))")

        self.callback?(self, event, userData)
    }

    private var eventHandlerUPP: EventHandlerUPP = { _, eventRef, userDataPtr -> OSStatus in
        guard let eventRef = eventRef else {
            return noErr
        }

        var hotKeyID = EventHotKeyID()

        let status = GetEventParameter(eventRef,
                                       EventParamName(kEventParamDirectObject),
                                       EventParamType(typeEventHotKeyID),
                                       nil,
                                       MemoryLayout<EventHotKeyID>.size,
                                       nil,
                                       &hotKeyID)

        if let hotKey = AppControllers.shared.hotKeysController.hotKey(forID: hotKeyID.id) {
            if status != noErr {
                hotKey.logger.log("GetEventParameter return error: \(status)")
            } else {
                var object: AnyObject?

                let event = NSEvent(eventRef: UnsafeRawPointer(eventRef))

                if let userData = userDataPtr == nil ? nil : UnsafeRawPointer(userDataPtr) {
                    object = bridge(userData)
                }

                hotKey.invoke(event, object)
            }
        }

        return status
    }

    public func register(withCallback callback: @escaping Callback) {
        self.callback = callback

        let eventHandlerBlock = self.eventHandlerUPP

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyReleased)

        // Install handler.
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            eventHandlerBlock,
            1,
            &eventType,
            self.userData != nil ? bridgeMutable(self.userData!) : nil,
            &self.eventHandlerRef)

        guard installStatus == noErr else {
            self.logger.error("got error from InstallEventHandler: \(installStatus)")
            return
        }

        // Register hotkey.
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         NSEvent.carbonModifierFlags(forModifierFlags: self.modifierFlags),
                                         self.hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &self.hotKeyRef)
        assert(status == noErr)
    }

    public var description: String {
        """
        \(type(of: self))
        """
    }
}
