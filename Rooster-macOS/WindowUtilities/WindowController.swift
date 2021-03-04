//
//  WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa
import RoosterCore

public class WindowController: NSWindowController, Loggable {
    
    private(set) static var visibleControllers: [NSWindowController] = []
    
    var autosaveKey: String?
    
    public init() {
        super.init(window: nil)
        
        self.shouldCascadeWindows = false
    }
    
    public override var windowNibName: NSNib.Name? {
        let name = String(describing: type(of: self))
        return name
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = self.window {
            window.isRestorable = false
            window.setFrameAutosaveName("")
        }
    }
    
    
    func setContentViewController(_ viewController: NSViewController) {
        self.contentViewController = viewController
        
        if let window = self.window {
            window.title = viewController.title ?? ""
            self.restoreWindowPositionOrSetInitialSize(viewController.preferredContentSize)
            self.registerForEvents()
        }
    }
    
    static func presentWithViewController(withContentViewController viewController: NSViewController,
                                          fromWindow window: NSWindow? = nil) {
        let windowController = WindowController()
        windowController.setContentViewController(viewController)
        self.presentWindowController(windowController,
                                     fromWindow: window)
    }
    
    static func presentWindowController(_ windowController: NSWindowController,
                                        fromWindow window: NSWindow? = nil) {
        
        if windowController.window != nil {
            
            self.logger.log("Presenting modal window for: \(String(describing:windowController)).\(String(describing:windowController.contentViewController))")
            
            if let parentWindow = window,
               let window = windowController.window {
                
                var frame = window.frame
                let parentFrame = parentWindow.frame
                
                frame.origin.x = parentFrame.origin.x + (parentFrame.size.width / 2) - (frame.size.width / 2)
                frame.origin.y = parentFrame.origin.y + (parentFrame.size.height / 2) - (frame.size.height / 2)
                window.setFrameOrigin(frame.origin)
            }
            
            windowController.showWindow(self)
            
            self.addWindowController(windowController)
            
            self.logger.log("Finished presenting modal window for: \(String(describing:windowController)).\(String(describing:windowController.contentViewController))")
            
        } else {
            self.logger.error("Failed to load window for \(windowController)")
        }
    }
    
    static func dismissWindow(forViewController viewController: NSViewController) {
        for visibleController in self.visibleControllers {
            if visibleController.contentViewController == viewController {
                visibleController.close()
                self.removeWindowController(visibleController)
                break
            }
        }
    }
    
    static func addWindowController(_ windowController: NSWindowController) {
        self.visibleControllers.append(windowController)
    }

    static func removeWindowController(_ windowController: NSWindowController) {
       if let index = self.visibleControllers.firstIndex(of: windowController) {
            self.visibleControllers.remove(at: index)
        }
    }
    
    public override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        _ = self.window // make sure it's loaded
        
        WindowController.addWindowController(self)
    }
    
    public override func close() {
        super.close()
        
        WindowController.removeWindowController(self)
    }
    
    func registerForEvents() {
//        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate(_:)), name: NSApplication.willTerminateNotification, object: nil)
        if let window = self.window {
            NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didMoveNotification, object: window)
            NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didResizeNotification, object: window)
            NotificationCenter.default.addObserver(self, selector: #selector(updateWindowFrame(_:)), name: NSWindow.didChangeScreenNotification, object: window)
//            NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.willCloseNotification, object: window)
        }
    }

    private func windowFrameKey(_ key: String) -> String {
        return "window-frame: \(key)"
    }
    
    @objc func updateWindowFrame(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window == self.window,
           let key = self.autosaveKey {

            let frameString = NSStringFromRect(window.frame)
            
            UserDefaults.standard.setValue(frameString, forKey: self.windowFrameKey(key))
            UserDefaults.standard.synchronize()
            
            self.logger.debug("Saved window frame: \(frameString) for window: \(key), for event: \(notification.name.rawValue)")
        }
    }
    
    @objc func windowWillClose(_ notification: Notification) {
//        if let nsWindow = notification.object as? NSWindow {
//            let key = nsWindow.savedPositionKey
//
//            if self.autoSaveNames.contains(key) {
//
//                self.logger.debug("Window will close: \(key)")
//
//                self.autoSaveNames.remove(key)
//            }
//        }
    }
    
    @objc func appWillTerminate(_ notification: Notification) {
        self.logger.debug("Application is terminating")
        
//        self.autoSaveNames.removeAll()
//        NotificationCenter.default.removeObserver(self)
    }
    
    func restoreWindowPositionOrSetInitialSize(_ initialSize: CGSize) {
        if let window = self.window {
            if let key = self.autosaveKey {
                self.logger.log("Restoring window: \(window.title): before: \(NSStringFromRect(window.frame))")
                
                if let frameString = UserDefaults.standard.object(forKey: self.windowFrameKey(key)) as? String {
                    var frame = NSRectFromString(frameString)
                
                    if initialSize != CGSize.zero {
                        frame.size = initialSize
                    }
                    
                    window.setFrame(frame, display: true)
                } else if initialSize != CGSize.zero {
                    window.setContentSize(initialSize)
                }

                self.logger.log("Restored window: \(window.title): after: \(NSStringFromRect(window.frame))")
            } else if initialSize != CGSize.zero {
                window.setContentSize(initialSize)
            }
        }
    }
    
}

