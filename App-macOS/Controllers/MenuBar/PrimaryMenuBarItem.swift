//
//  PrimaryMenuBarItem.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 1/31/21.
//

import Foundation
import AppKit

class PrimaryMenuBarItem: MenuBarItem, CountDownDelegate  {

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
    
    @objc override func preferencesDidChange(_ sender: Notification) {
        self.isVisible = prefs.options.contains(.showIcon)
    }

    
}
