//
//  MenuBarMenu.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import AppKit

class MenuBarMenuItem: CountDownDelegate, Loggable, DataModelAware, AppControllerAware  {

    private lazy var countDown = CountDown(withDelegate: self)
    
    static let defaultImageSize = CGSize(width: 26, height: 26)
    private var reloader: DataModelReloader? = nil

    private weak var timer: Timer?
    
    private var showingRedRooster = false

    let menuItemViewController = MenuBarItemViewController()
    
    init() {
        self.reloader = DataModelReloader(for: self)
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesDidChange(_:)), name: PreferencesController.DidChangeEvent, object: nil)

        self.buttonImage = self.defaultRoosterImage
    }
    
    deinit {
        self.stopFlashingTimer()
        self.countDown.stop()
    }
    
    var buttonImage: NSImage? {
        didSet {
            if let button = self.button {
                if let image = self.buttonImage {
                    button.image = image
                } else {
                    button.image = nil
                }
            }
        }
    }
    
    var prefs: MenuBarPreferences {
        return self.preferencesController.menuBarPreferences
    }
    
    var contentTintColor: NSColor? {
        get {
            if let button = self.button,
                let color = button.contentTintColor {
                return color
            }
            return nil
        }
        set(color) {
            if let button = self.button {
                return button.contentTintColor = color
            }
        }
    }
    
    var button: NSButton? {
        if let button = self.statusBarItem.button {
            return button
        }
        
        return nil
    }
    
    var buttonTitle: String {
        get {
            if let button = self.button {
                return button.title
            }
            return ""
        }
        set(title) {
            if let button = self.button {
                return button.title = title
            }
        }
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
        }
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
    
    func visibilityDidChange(toVisible visible: Bool) {
        self.alarmStateDidChange()
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.alarmStateDidChange()
    }
    
    // these are actually handled by the appdelegate but the compiler wants them
//    @IBAction @objc func fileRadar(_ sender: Any) {
//    }
//
//    @IBAction @objc func openRepoURL(_ sender: Any) {
//    }
//
//    @IBAction @objc func checkForUpdates(_ sender: Any) {
//    }
//
//    @IBAction @objc func showPreferences(_ sender: Any) {
//    }
//
//    @IBAction @objc func stopAllAlarms(_ sender: Any) {
//    }
//
//    @IBAction @objc func bringAppToFront(_ sender: Any) {
//    }
//
//    @IBAction @objc func quitRooster(_ sender: Any) {
//    }
//
    @IBAction @objc func eventListWasClicked(_ sender: Any) {

    }
    
   
    
    @objc func preferencesDidChange(_ sender: Notification) {
        self.isVisible = prefs.options.contains(.showIcon)
    }

    func createStatusBarItem() -> NSStatusItem {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        statusBarItem.menu = self.menuItemViewController.menuBarMenu
    
        if let button = statusBarItem.button {
            button.image = self.buttonImage
            button.imagePosition = .imageTrailing
        }
        
        return statusBarItem
    }
    
    lazy var statusBarItem: NSStatusItem = {
        self.createStatusBarItem()
    }()

    var isVisible: Bool {
        get {
            return self.statusBarItem.isVisible
        }
        
        set(visible) {
            self.statusBarItem.isVisible = visible
            self.visibilityDidChange(toVisible: visible)
        }
    }
    
    
}

