//
//  MouseTracker.swift
//  Rooster
//
//  Created by Mike Fullerton on 2/21/21.
//

import Foundation

import AppKit

public class MouseTracker {
    private var trackingAreas: [NSTrackingArea]?
    private var wasPostingFrameChanges: Bool

    private(set) weak var view: NSView?

    public init(withView view: NSView) {
        self.view = view
        self.wasPostingFrameChanges = false
    }

    public var isTrackingEnabled = false {
        didSet {
            if let view = self.view {
                if self.isTrackingEnabled {
                    self.updateTrackingArea()
                    self.wasPostingFrameChanges = view.postsFrameChangedNotifications
                    view.postsFrameChangedNotifications = true
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(frameDidChange(_:)),
                                                           name: NSView.frameDidChangeNotification,
                                                           object: view)
                } else {
                    self.removeTrackingAreas()
                    view.postsFrameChangedNotifications = self.wasPostingFrameChanges
                    NotificationCenter.default.removeObserver(self,
                                                              name: NSView.frameDidChangeNotification,
                                                              object: view)
                }
            }
        }
    }

    private func removeTrackingAreas() {
        if let view = self.view,
            let trackingViewAreas = self.trackingAreas {
            trackingViewAreas.forEach { view.removeTrackingArea($0) }

            self.trackingAreas = nil
        }
    }

    private func updateTrackingArea() {
        self.removeTrackingAreas()

        if let view = self.view {
            var areas: [NSTrackingArea] = []

//            print("tracking: updating view:\(type(of: view)), tracking rect: \(NSStringFromRect(view.frame))")

            areas.append( NSTrackingArea(rect: view.bounds,
                                         options: [ .mouseEnteredAndExited, .activeAlways, .enabledDuringMouseDrag ],
                                         owner: view,
                                         userInfo: nil))

            areas.append( NSTrackingArea(rect: view.bounds,
                                         options: [ NSTrackingArea.Options.mouseMoved, .activeAlways, .enabledDuringMouseDrag ],
                                         owner: view,
                                         userInfo: nil))

            self.trackingAreas = areas
            areas.forEach { view.addTrackingArea($0) }
        }
    }

    @objc func frameDidChange(_ notification: Notification) {
        if let view = self.view,
            let sendingView = notification.object as? NSView,
            sendingView == view {
            self.updateTrackingArea()
        }
    }
}
