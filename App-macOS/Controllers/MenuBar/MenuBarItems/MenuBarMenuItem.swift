//
//  MenuBarMenu.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import AppKit

class MenuBarMenuItem: MenuBarItem, CountDownDelegate  {

    private lazy var countDown = CountDown(withDelegate: self)
    
    private weak var timer: Timer?
    
    private var showingRedRooster = false

    override init() {
        super.init()
        self.buttonImage = self.defaultRoosterImage
    }
    
    deinit {
        self.stopFlashingTimer()
        self.countDown.stop()
    }
    
    private var redRoosterImage : NSImage? {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            return image
        }
        
        return nil
    }
    
    private var defaultRoosterImage: NSImage? {
        if let image = self.redRoosterImage {
            image.isTemplate = true
            return image.tint(color: NSColor.white)
        }
            
        return nil
    }
    
    func startCountdown() {
        if self.prefs.options.contains(.countDown) {
            self.countDown.start()
        } else {
            self.stopCountdown()
        }
    }
    
    func stopCountdown() {
        self.countDown.stop()
        self.buttonTitle = ""
    }
    
    func countdown(_ countDown: CountDown, didUpdate displayString: String) {
        self.buttonTitle = displayString
    }
    
    func countdownFireDate(_ countDown: CountDown) -> Date? {
        return self.dataModelController.dataModel.nextAlarmDate
    }

    func countdownDisplayFormatter(_ countDown: CountDown) -> CountDownStringFormatter {
        return self.prefs.options.contains(.shortCountdownFormat) ?
            ShortCountDownStringFormatter(showSecondsWithMinutes: 2.0):
            LongCountDownStringFormatter(showSecondsWithMinutes: 2.0)
    }
    
    func countdown(_ countDown: CountDown, didFinish displayString: String) {
        self.buttonTitle = displayString
    }
   
    func countdown(_ countDown: CountDown, willStart: Bool) {
        self.buttonTitle = ""
    }
    
    @objc override func buttonClicked(_ sender: AnyObject?) {
        self.logger.log("MenuBar button was clicked")
        self.isPopoverVisible = !self.isPopoverVisible
    }
    
    private lazy var popover : NSPopover = {
        
        let controller = MainWindowViewController()
        
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = controller
        popover.contentSize = controller.preferredContentSize
        return popover
    }()
    
    var isPopoverVisible: Bool {
        get {
            return self.popover.isShown
        }
        set(show) {
            if let button = self.button {
                if show && !self.popover.isShown {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                } else if !show && self.popover.isShown {
                    self.popover.performClose(self)
                }
            }

        }
    }
    
    private func toggleImages() {
        self.showingRedRooster = !self.showingRedRooster
        if self.showingRedRooster {
            self.buttonImage = self.redRoosterImage
        } else {
            self.buttonImage = self.defaultRoosterImage
        }
    }
    
    var isAlarmFiring: Bool {
        return self.alarmNotificationController.alarmsAreFiring
    }
    
    func alarmStateDidChange() {
        if self.prefs.options.contains(.showIcon) {
            if self.isAlarmFiring {
                self.showingRedRooster = true
                self.buttonImage = self.redRoosterImage
                self.startFlashingTimer()
                self.stopCountdown()
                self.showFinishedMessage()
            } else {
                self.showingRedRooster = false
                self.buttonImage = self.defaultRoosterImage
                self.stopFlashingTimer()
                self.startCountdown()
            }
        } else {
            self.stopCountdown()
            self.stopFlashingTimer()
            self.isPopoverVisible = false
        }
        
        self.stopAlarmsMenuItem.isHidden = !self.isAlarmFiring
        
        self.menuItemView.updateViewSize()
    }
    
    func startFlashingTimer() {
        if self.preferencesController.menuBarPreferences.options.contains(.blink) {
            if self.timer == nil {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                    if self.isAlarmFiring {
                        self.toggleImages()
                    } else {
                        self.stopFlashingTimer()
                    }
                }
                self.timer = timer
            }
        } else {
            self.stopFlashingTimer()
            self.buttonImage = self.defaultRoosterImage
        }
    }
    
    func stopFlashingTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func showFinishedMessage() {
        if self.prefs.options.contains(.countDown) {
            self.buttonTitle = "Your meeting has started!"
        } else {
            self.buttonTitle = ""
        }
    }
    
    override func visibilityDidChange(toVisible visible: Bool) {
        self.alarmStateDidChange()
    }
    
    override func dataModelDidReload(_ dataModel: DataModel) {
        self.alarmStateDidChange()
    }
    
    // these are actually handled by the appdelegate but the compiler wants them
    @IBAction @objc func fileRadar(_ sender: Any) {
    }
    
    @IBAction @objc func openRepoURL(_ sender: Any) {
    }
   
    @IBAction @objc func checkForUpdates(_ sender: Any) {
    }
    
    @IBAction @objc func showPreferences(_ sender: Any) {
    }
    
    @IBAction @objc func stopAllAlarms(_ sender: Any) {
    }

    @IBAction @objc func bringAppToFront(_ sender: Any) {
    }

    @IBAction @objc func quitRooster(_ sender: Any) {
    }
    
    @IBAction @objc func eventListWasClicked(_ sender: Any) {
        
    }
    
    lazy var menuItemView = MenuItemView()
    
    lazy var eventsMenuItem:NSMenuItem = {
        let menuItem = NSMenuItem(title: "Custom", action: #selector(eventListWasClicked(_:)), keyEquivalent: "")
        menuItem.view = self.menuItemView
        return menuItem
    }()
    
    lazy var stopAlarmsMenuItem = NSMenuItem(title: "Stop Alarms",
                                             action: #selector(stopAllAlarms(_:)),
                                             keyEquivalent: self.preferencesController.menuBarPreferences.keyEquivalent(for: .stopAlarms))
    
    lazy var menu: NSMenu = {
        let menu = NSMenu()

        menu.addItem(self.stopAlarmsMenuItem)
        
        menu.addItem(NSMenuItem(title: "Bring Rooster to front",
                                action: #selector(bringAppToFront(_:)),
                                keyEquivalent: self.preferencesController.menuBarPreferences.keyEquivalent(for: .bringToFrong)))

        
        menu.addItem(self.eventsMenuItem)
        
        menu.addItem(NSMenuItem(title: "Preferences...",
                                action: #selector(showPreferences(_:)),
                                keyEquivalent: self.preferencesController.menuBarPreferences.keyEquivalent(for: .showPreferences)))

        menu.addItem(NSMenuItem(title: "Quit Rooster",
                                action: #selector(quitRooster(_:)),
                                keyEquivalent: ""))
        return menu
    }()
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.isVisible = prefs.options.contains(.showIcon)
    }

    override func createStatusBarItem() -> NSStatusItem {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        statusBarItem.menu = self.menu
    
        if let button = statusBarItem.button {
            button.image = self.buttonImage
            button.imagePosition = .imageTrailing
        }
        
        return statusBarItem
    }
    
}

