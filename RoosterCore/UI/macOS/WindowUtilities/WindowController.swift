//
//  WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa

open class WindowController: NSWindowController, Loggable {
    private(set) static var visibleControllers: [NSWindowController] = []

    public var autosaveKey: String?

    public var deferredSave = DeferredCallback()

    public init() {
        super.init(window: nil)

        self.shouldCascadeWindows = false
    }

    override public var windowNibName: NSNib.Name? {
        let name = String(describing: type(of: self))
        return name
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func windowDidLoad() {
        super.windowDidLoad()

        if let window = self.window {
            window.isRestorable = false
            window.setFrameAutosaveName("")
        }
    }

    override open var contentViewController: NSViewController? {
        get {
            super.contentViewController
        }
        set(viewController) {
            super.contentViewController = viewController

            if let keyViewProviding = viewController as? KeyViewProviding {
                _ = viewController?.view // make sure it's loaded
                self.window?.initialFirstResponder = keyViewProviding.initialKeyViewForWindow
            }

            self.window?.title = viewController?.title ?? ""
        }
    }

    open func restoreVisibleState() {
        let window = self.window // make sure it's loaded

        assert(window != nil, "window is nil")
        assert(self.contentViewController != nil, "view controller is nil")

        if let viewController = self.contentViewController {
            if self.autosaveKey != nil {
                self.restoreWindowPositionOrSetInitialSize(viewController.preferredContentSize)
                self.registerForEvents()
            }
        }
    }

    public static func presentWithViewController(withContentViewController viewController: NSViewController,
                                                 fromWindow window: NSWindow? = nil) {
        let windowController = WindowController()
        windowController.contentViewController = viewController
        windowController.restoreVisibleState()
        self.presentWindowController(windowController,
                                     fromWindow: window)
    }

    public static func presentWindowController(_ windowController: NSWindowController,
                                               fromWindow window: NSWindow? = nil) {
        if windowController.window != nil {
            self.logger.log("""
                Presenting modal window for: \
                \(String(describing: windowController)).\(String(describing: windowController.contentViewController))
                """)

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

            self.logger.log("""
                Finished presenting modal window for: \
                \(String(describing: windowController)).\(String(describing: windowController.contentViewController))
                """)
        } else {
            self.logger.error("Failed to load window for \(windowController)")
        }
    }

    public static func dismissWindow(forViewController viewController: NSViewController) {
        for visibleController in self.visibleControllers where visibleController.contentViewController == viewController {
            visibleController.close()
            self.removeWindowController(visibleController)
            break
        }
    }

    public static func addWindowController(_ windowController: NSWindowController) {
        self.visibleControllers.append(windowController)
    }

    public static func removeWindowController(_ windowController: NSWindowController) {
       if let index = self.visibleControllers.firstIndex(of: windowController) {
            self.visibleControllers.remove(at: index)
        }
    }

    override open func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        _ = self.window // make sure it's loaded

        WindowController.addWindowController(self)
        self.windowStateDidUpdate()
    }

    override open func close() {
        super.close()

        WindowController.removeWindowController(self)
        self.windowStateDidUpdate()
    }

    private func registerForEvents() {
        if let window = self.window {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateWindowState(_:)),
                                                   name: NSWindow.didMoveNotification,
                                                   object: window)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateWindowState(_:)),
                                                   name: NSWindow.didResizeNotification,
                                                   object: window)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateWindowState(_:)),
                                                   name: NSWindow.didChangeScreenNotification,
                                                   object: window)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateWindowState(_:)),
                                                   name: NSWindow.willCloseNotification,
                                                   object: window)
        }
    }

    private var windowFrameAutoSaveKey: String? {
        if let key = self.autosaveKey {
            return key + ".window-frame"
        }

        return nil
    }

    private var isVisibleAutoSaveKey: String? {
        if let key = self.autosaveKey {
            return key + ".is-visible"
        }

        return nil
    }
    // swiftlint:disable legacy_objc_type discouraged_optional_boolean

    public var savedVisibleState: Bool? {
        get {
            if let key = self.isVisibleAutoSaveKey,
               let object = UserDefaults.standard.value(forKey: key) as? NSNumber {
                return object.boolValue
            }
            return nil
        }
        set {
            if let key = self.isVisibleAutoSaveKey {
                if let newValue = newValue {
                    UserDefaults.standard.set(newValue, forKey: key)
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
                self.logger.debug("Saved window visible: \(String(describing: newValue)) for window: \(key)")
            }
        }
    }

    public var savedWindowFrame: CGRect? {
        get {
            if let key = self.windowFrameAutoSaveKey,
               let rectString = UserDefaults.standard.value(forKey: key) as? String {
                return NSRectFromString(rectString)
            }
            return nil
        }
        set {
            if let key = self.windowFrameAutoSaveKey {
                if let newValue = newValue {
                    let frameString = NSStringFromRect(newValue)
                    UserDefaults.standard.set(frameString, forKey: key)
                    self.logger.debug("Saved window frame: \(frameString) for window: \(key)")
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
        }
    }

    public func windowStateDidUpdate() {
        if let window = self.window {
            self.savedWindowFrame = window.frame
            self.savedVisibleState = window.isVisible
            UserDefaults.standard.synchronize()
        }
    }

    @objc open func updateWindowState(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == self.window {
            self.deferredSave.schedule { [weak self] in
                guard let self = self else { return }
                self.logger.debug("received window event: \(notification.name.rawValue) for window: \(window.title)")
                self.windowStateDidUpdate()
            }
        }
    }

    private func restoreWindowPositionOrSetInitialSize(_ initialSize: CGSize) {
        if let window = self.window {
            self.logger.log("Restoring window: \(window.title): before: \(String(describing: window.frame))")

            if var frame = self.savedWindowFrame {
                if initialSize != CGSize.zero {
                    frame.size = initialSize
                }

                window.setFrame(frame, display: true)
            } else {
                window.setContentSize(initialSize)
            }

            let savedVisibleState = self.savedVisibleState

            if savedVisibleState ?? true {
                self.showWindow(self)
            }

            self.logger.log("""
                Restored window: \(window.title): \
                after: \(String(describing: window.frame)), \
                visible: \(String(describing: savedVisibleState))
                """)
        }
    }

    // swiftlint:enable legacy_objc_type
}
