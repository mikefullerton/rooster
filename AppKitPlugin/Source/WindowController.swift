//
//  WindowController.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

import Foundation
import AppKit

class WindowController : NSObject, AppKitWindowController, Loggable {
    
    private var helper = WindowControllerHelper()
    
    private var autoSaveNames:Set<String> = Set<String>()
    
    override init() {
        super.init()
        self.registerForEvents()
        
    }
    
    func registerForEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate(_:)), name: NSApplication.willTerminateNotification, object: nil)
        
        self.registerForEvents(fromWindow: nil)
    }

    func registerForEvents(fromWindow window: NSWindow?) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didMoveNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didResizeNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didChangeScreenNotification, object: window)
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: window)
    }

    @objc func updateWindowFrame(_ notification: Notification) {
        if let nsWindow = notification.object as? NSWindow {
            let key = nsWindow.savedPositionKey

            if self.autoSaveNames.contains(key){
                    
                let frameString = NSStringFromRect(nsWindow.frame)
                
                UserDefaults.standard.setValue(frameString, forKey: key)
                
                self.logger.debug("Saved window frame for window: \(key), for event: \(notification.name.rawValue)")
            }
        }
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        if let nsWindow = notification.object as? NSWindow {
            let key = nsWindow.savedPositionKey
            
            if self.autoSaveNames.contains(key) {
                
                self.logger.debug("Window will close: \(key)")
                
                self.autoSaveNames.remove(key)
            }
        }
    }
    
    @objc func appWillTerminate(_ notification: Notification) {
        self.logger.debug("Application is terminating")
        
//        self.autoSaveNames.removeAll()
//        NotificationCenter.default.removeObserver(self)
    }
    
    func restoreWindowPosition(forWindow uiWindow: Any, windowName name: String) {
        if name.count > 0,
           let nsWindow = self.helper.hostWindow(forUIWindow: uiWindow) {
            
            let key = nsWindow.savedPositionKey
            
            self.logger.log("Restoring window: \(nsWindow.title): before: \(NSStringFromRect(nsWindow.frame))")
            
            if let frameString = UserDefaults.standard.object(forKey: key) as? String {
                let frame = NSRectFromString(frameString)
                nsWindow.setFrame(frame, display: true)
            }
            
            self.logger.log("Restored window: \(nsWindow.title): after: \(NSStringFromRect(nsWindow.frame))")
            
            self.autoSaveNames.insert(key)
        }
    }
    
    func bringWindow(toFront window: Any) {
        if let nsWindow = self.helper.hostWindow(forUIWindow: window) {
            nsWindow.makeKeyAndOrderFront(self)
        }
            
    }
    
    
    
}

extension NSWindow {
    public var savedPositionKey: String {
        return "saved-frame-\(self.title)"
    }
}
