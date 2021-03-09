//
//  KeyboardShortcutInterceptor.swift
//  RoosterCore-macOS
//
//  Created by Mike Fullerton on 4/25/21.
//
import Cocoa
import Foundation

public class KeyboardShortcutInterceptor: Loggable {
    private var eventTap: CFMachPort?

    public var callback: (_ event: NSEvent) -> NSEvent?

    private var runLoopSource: CFRunLoopSource?

    public init(callback: @escaping (_ event: NSEvent) -> NSEvent?) {
        self.callback = callback

//        self.install()
    }

    public func install() {
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        if let eventTap = CGEvent.tapCreate(tap: CGEventTapLocation.cghidEventTap,
                                            place: CGEventTapPlacement.headInsertEventTap,
                                            options: CGEventTapOptions.defaultTap,
                                            eventsOfInterest: CGEventMask(CGEventType.keyDown.rawValue),
                                            callback: { _, eventType, cgEvent, userInfo -> Unmanaged<CGEvent>? in
                                                print("Got event: \(String(describing: cgEvent))")

                                            guard eventType != .tapDisabledByTimeout else {
                                                return nil
                                            }
                                            guard let event = NSEvent(cgEvent: cgEvent),
                                                  let selfPtr = userInfo?.load(as: KeyboardShortcutInterceptor.self) else {
                                                return Unmanaged<CGEvent>.passUnretained(cgEvent)
                                            }

                                            if let newEvent = selfPtr.callback(event),
                                               let newCgEvent = newEvent.cgEvent {
                                                return Unmanaged<CGEvent>.passRetained(newCgEvent)
                                            }

                                            return nil
                                          },
                                          userInfo: selfPointer ) {
            self.eventTap = eventTap

            let runLoopSource = CFMachPortCreateRunLoopSource(nil, eventTap, 0)

            self.runLoopSource = runLoopSource

            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)

            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    public func uninstall() {
        if let eventTap = self.eventTap {
            if let runLoopSource = self.runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
                self.runLoopSource = nil
            }

            CGEvent.tapEnable(tap: eventTap, enable: false)

//            CFMachPortInvalidate(self.eventTap)
            self.eventTap = nil
        }
    }

    deinit {
        self.uninstall()
    }
//
//    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap,
//    kCGHeadInsertEventTap,
//    kCGEventTapOptionDefault,
//    CGEventMaskBit(kCGEventKeyDown),
//    &KeyDownCallback,
//    NULL);
//
//    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(NULL, eventTap, 0);
//    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
//    CFRelease(runLoopSource);
//    CGEventTapEnable(eventTap, true);

//        static CGEventRef KeyDownCallback(CGEventTapProxy proxy,
//    CGEventType type,
//    CGEventRef event,
//    void *refcon)
//    {
//    /* Do something with the event */
//    NSEvent *e = [NSEvent eventWithCGEvent:event];
//    return event;
//    }
}
