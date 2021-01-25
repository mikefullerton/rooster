//
//  MenubarPopover.swift
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/18/20.
//

import Foundation
import AppKit

protocol MenuBarControllerDelegate : AnyObject {

    func menuBarControllerButtonWasClicked(_ controller: MenuBarController)
    
    func menuBarControllerAreAlarmsFiring(_ controller: MenuBarController) -> Bool
    
    func menuBarControllerNextFireDate(_ controller: MenuBarController) -> Date?

}

class MenuBarController: NSObject, Loggable {
        
    struct Option: OptionSet {
        let rawValue: Int
        
        static let none             = Option(rawValue: 1 << 0)
        static let icon             = Option(rawValue: 1 << 1)
        static let countDown        = Option(rawValue: 1 << 2)
    }
    
    public weak var delegate: MenuBarControllerDelegate?
    
    private var statusBarItem: NSStatusItem? = nil
    private let countDownTimer = SimpleTimer(withName: "MenuBarCountDownTimer")
    
    private weak var timer: Timer?
    
    var showingRedRooster = false
    
    var displayOptions: Option = [.icon, .countDown] {
        didSet {
            self.updateMenuBarItemsVisibility()
        }
    }
    deinit {
        self.stopFlashingTimer()
        self.countDownTimer.stop()
    }
    
    var redRoosterImage : NSImage? {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            
            return image
        }
        
        return nil
    }
    
    var defaultRoosterImage: NSImage? {
        if let image = self.redRoosterImage {
            image.isTemplate = true
            return image.tint(color: NSColor.white)
        }
            
        return nil
    }
    
    func setStatusBarIconImage(_ inImage: NSImage?) {
        if let image = inImage,
           let statusBarItem = self.statusBarItem,
           let button = statusBarItem.button {
           
            image.size = CGSize(width: 26, height: 26)
            button.image = image
        }
    }
    
    func showIconInMenuBar() {
        
        if self.displayOptions.contains(.icon) && self.statusBarItem == nil {
            let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
            
            if let button = statusBarItem.button,
               let image = self.defaultRoosterImage {
                
                image.size = CGSize(width: 26, height: 26)
                button.image = image
                button.action = #selector(buttonClicked(_:))
                button.target = self
                button.imagePosition = .imageLeading
            }
            
            if self.displayOptions.contains(.icon) {
                self.updateCountdown()
            }
            
            self.statusBarItem = statusBarItem
        }
        
    }
    
    func hideIconInMenuBar() {
        if let statusBarItem = self.statusBarItem {
            NSStatusBar.system.removeStatusItem(statusBarItem)
            self.statusBarItem = nil
        }
    }
    
    func updateCountdown() {
        
        if let delegate = self.delegate {
        
            if let statusBarItem = self.statusBarItem,
               let button = statusBarItem.button {
            
                var title: String = ""
                
                if let nextFireDate = delegate.menuBarControllerNextFireDate(self) {
                    let countDown = CountDown(withFireDate: nextFireDate,
                                              formatter: LongCountDownStringFormatter(),
                                              showSecondsWithMinutes: false)

                    title = countDown.displayString
                }
                
                button.title = title
            }

            self.countDownTimer.logTimerEvents = false
            self.countDownTimer.start(withInterval: 1.0, fireCount: 1) { [weak self] timer in
                if let strongSelf = self {
                    strongSelf.updateCountdown()
                }
            }
        }
    }

    @objc func buttonClicked(_ sender: AnyObject?) {
        self.logger.log("MenuBar button was clicked")
        if let delegate = self.delegate {
            delegate.menuBarControllerButtonWasClicked(self)
        }
    }
    
    lazy var popoverViewController : NSViewController = {
        return MenuBarPopoverViewController()
    }()
    

    lazy var popover : NSPopover = {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = self.popoverViewController
        return popover
    }()
    
    var isPopoverHidden: Bool {
        get {
            return !self.popover.isShown
        }
        set(hidden) {
            if let button = self.statusBarItem?.button {
                if hidden && self.popover.isShown {
                    self.popover.performClose(self)
                } else if !hidden && !self.popover.isShown {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }

        }
    }
    
    func toggleImages() {
        self.showingRedRooster = !self.showingRedRooster
        if self.showingRedRooster {
            self.setStatusBarIconImage(self.redRoosterImage)
        } else {
            self.setStatusBarIconImage(self.defaultRoosterImage)
        }
    }
    
    var isAlarmFiring: Bool {
        if let delegate = self.delegate {
            return delegate.menuBarControllerAreAlarmsFiring(self)
        }
        
        return false
    }
    
    func alarmStateDidChange() {
        if self.isAlarmFiring {
            self.showingRedRooster = true
            self.setStatusBarIconImage(self.redRoosterImage)
            self.startFlashingTimer()
        } else {
            self.showingRedRooster = false
            self.setStatusBarIconImage(self.defaultRoosterImage)
            self.stopFlashingTimer()
        }
    }
    
    func startFlashingTimer() {
        self.stopFlashingTimer()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            if self.isAlarmFiring {
                self.toggleImages()
            } else {
                self.stopFlashingTimer()
            }
        }
        self.timer = timer
    }
    
    func stopFlashingTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func showNowFiringItem(_ item: Any) {
        self.isPopoverHidden = false
    }
    
    func hideNowFiringItem(_ item: Any) {
        self.isPopoverHidden = true
    }
    
    func updateMenuBarItemsVisibility() {
        
    }
}
