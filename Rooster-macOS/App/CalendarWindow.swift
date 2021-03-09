//
//  CalendarWindow.swift
//  Rooster
//
//  Created by Mike Fullerton on 3/1/21.
//

import Cocoa
import RoosterCore

public class CalendarWindow: WindowController {
    private static weak var instance: CalendarWindow?

    @IBOutlet private var viewController: CalendarChooserViewController?

    override public func windowDidLoad() {
        super.windowDidLoad()
        self.autoSaveKey = AutoSaveKey("Calendars", alwaysShow: true)

        self.contentViewController = viewController
    }

    static func show() {
        if let windowController = CalendarWindow.instance,
           let window = windowController.window {
            window.makeKeyAndOrderFront(self)
        } else {
            let windowController = CalendarWindow()
            self.instance = windowController

            windowController.showWindow(self)
        }
    }
}
