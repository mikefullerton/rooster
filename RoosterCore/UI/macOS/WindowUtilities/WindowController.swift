//
//  WindowController.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/22/21.
//

import Cocoa

open class WindowController: NSWindowController, Loggable {
    private(set) static var visibleControllers: [NSWindowController] = []

    public var autoSaveKey: AutoSaveKey?

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

        self.registerForEvents()
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

    open func restoreVisibleState() -> Bool {
        let window = self.window // make sure it's loaded

        assert(window != nil, "window is nil")
        assert(self.contentViewController != nil, "view controller is nil")

        if let viewController = self.contentViewController {
            if self.autoSaveKey != nil {
                self.restoreWindowPositionOrSetInitialSize(viewController.preferredContentSize)

                return true
            }
        }

        return false
    }

    public func show() {
        if !self.restoreVisibleState() {
            self.showCenteredOnMainScreen()
        }
        Self.addWindowController(self)
    }

    public static func bringToFront(withContentViewController viewController: NSViewController,
                                    autoSaveKey: AutoSaveKey? = nil) -> Bool {
        for windowController in self.visibleControllers {
            if windowController.contentViewController == viewController {
                windowController.window?.makeKeyAndOrderFront(self)
                return true
            }

            if autoSaveKey != nil,
               let windowController = windowController as? WindowController,
               windowController.autoSaveKey == autoSaveKey {
                windowController.window?.makeKeyAndOrderFront(self)
                return true
            }
        }
        return false
    }

    public static func show(withContentViewController viewController: NSViewController,
                            autoSaveKey: AutoSaveKey? = nil) {
        if !self.bringToFront(withContentViewController: viewController, autoSaveKey: autoSaveKey) {
            let windowController = WindowController()
            windowController.contentViewController = viewController
            windowController.autoSaveKey = autoSaveKey
            windowController.show()
        }
    }

    public static func show(withContentViewController viewController: NSViewController,
                            centeredOnWindow window: NSWindow) {
        if !self.bringToFront(withContentViewController: viewController) {
            let windowController = WindowController()
            windowController.contentViewController = viewController
            windowController.show(centeredOnWindow: window)
        }
    }

    public func show(centeredOnWindow parentWindow: NSWindow) {
        guard let window = self.window else {
            return
        }

        guard let contentViewController = self.contentViewController else {
            return
        }

        guard Self.bringToFront(withContentViewController: contentViewController) == false else {
            return
        }

        let contentSize = contentViewController.preferredContentSize
        guard contentSize.width > 0, contentSize.height > 0 else {
            assertionFailure("invalid content size")
            return
        }

        guard let screen = parentWindow.screen else {
            assertionFailure("main screen is nil!")
            return
        }

        let containingFrame = parentWindow.frame

        let screenFrame = screen.frame

        var windowFrame = window.frame
        windowFrame.origin.y = screenFrame.origin.y
        windowFrame.size = contentSize
        windowFrame = windowFrame.constrainHeightVerticallyFlipped(inContainingRect: screenFrame)
        windowFrame.center(in: containingFrame)
        window.setFrame(windowFrame, display: false)
        self.showWindow(self)
    }

    public static func hide(forViewController viewController: NSViewController) {
        for visibleController in self.visibleControllers where visibleController.contentViewController == viewController {
            visibleController.close()
            self.removeWindowController(visibleController)
            break
        }
    }

    public static func addWindowController(_ windowController: NSWindowController) {
        if !self.visibleControllers.contains(windowController) {
            self.visibleControllers.append(windowController)
        }
    }

    public static func removeWindowController(_ windowController: NSWindowController) {
       if let index = self.visibleControllers.firstIndex(of: windowController) {
            self.visibleControllers.remove(at: index)
        }
    }

    override open func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        _ = self.window // make sure it's loaded

        Self.addWindowController(self)
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

    public func windowStateDidUpdate() {
        if let autoSaveKey = self.autoSaveKey {
            _ = self.saveState(withAutoSaveKey: autoSaveKey)
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
        guard let window = self.window else {
            assertionFailure("window is nil")
            return
        }

        defer {
            self.logger.log(
                """
                Restored window: \(window.title): \
                before: \(String(describing: window.frame)), \
                after: \(String(describing: window.frame)), \
                visible: \(window.isVisible)
                """)
        }

        if let autoSaveKey = self.autoSaveKey {
            if self.restoreState(withAutoSaveKey: autoSaveKey, initialSize: initialSize) {
                return
            }
        }

        guard let screen = NSScreen.main else {
            assertionFailure("main screen is nil!")
            return
        }

        let mainScreenFrame = screen.frame

        var windowFrame = window.frame
        if initialSize != CGSize.zero {
            windowFrame.origin.y = mainScreenFrame.origin.y
            windowFrame.size = initialSize
            windowFrame = windowFrame.constrainHeightVerticallyFlipped(inContainingRect: mainScreenFrame)
        }
        windowFrame.center(in: mainScreenFrame)
        window.setFrame(windowFrame, display: false)

        self.showWindow(self)
    }
}

extension NSWindowController {
    public struct AutoSaveKey: Equatable {
        public let key: String
        public let alwaysShow: Bool

        public init(_ key: String, alwaysShow: Bool = false) {
            self.key = key
            self.alwaysShow = alwaysShow
        }
    }

    public func showCenteredOnMainScreen() {
        guard let window = self.window else {
            assertionFailure("window is nil")
            return
        }

        guard let screen = NSScreen.main else {
            assertionFailure("main screen is nil!")
            return
        }

        guard let contentViewController = self.contentViewController else {
            assertionFailure("no view controller")
            return
        }

        let mainScreenFrame = screen.frame

        let contentSize = contentViewController.preferredContentSize
        guard contentSize.width > 0, contentSize.height > 0 else {
            assertionFailure("invalid content size")
            return
        }

        var windowFrame = window.frame
        windowFrame.origin.y = mainScreenFrame.origin.y
        windowFrame.size = contentSize
        windowFrame = windowFrame.constrainHeightVerticallyFlipped(inContainingRect: mainScreenFrame)
        windowFrame.center(in: mainScreenFrame)
        window.setFrame(windowFrame, display: false)

        self.showWindow(self)
    }

    public func setContentSizeWithHeightConstrainedByScreen(_ size: CGSize) {
        guard let window = self.window else {
            return
        }

        window.setContentSizeWithHeightConstrainedByScreen(size)
    }
}

extension NSWindow {
    public func setContentSizeWithHeightConstrainedByScreen(_ size: CGSize) {
        let windowFrame = self.frame
        let bottom = self.frame.maxY
        var frame = self.frameRect(forContentRect: CGRect(origin: windowFrame.origin, size: size))
        frame.origin.y = bottom - frame.size.height
        if let adjusted = self.frameRectWithAdjustedHeightConstrainedByScreen(frame) {
            self.setFrame(adjusted, display: self.isVisible, animate: self.isVisible)
        }
    }

    public func frameRectWithAdjustedHeightConstrainedByScreen(_ frame: CGRect) -> CGRect? {
        guard let screen = self.screen else {
            return nil
        }

        return frame.constrainHeightVerticallyFlipped(inContainingRect: screen.frame)
    }

    public func centeredFrameInScreen(frame: CGRect) -> CGRect? {
        guard let screen = self.screen else {
            return nil
        }

        return frame.centered(in: screen.frame)
    }
}

extension CGRect {
    public func constrainHeightVerticallyFlipped(inContainingRect containingRect: CGRect) -> CGRect {
        guard self.origin.y < containingRect.origin.y else {
            return self
        }
        var outRect = self
        outRect.size.height -= (max(containingRect.origin.y, outRect.origin.y) - min(containingRect.origin.y, outRect.origin.y))
        outRect.origin.y = containingRect.origin.y
        return outRect
    }
}
