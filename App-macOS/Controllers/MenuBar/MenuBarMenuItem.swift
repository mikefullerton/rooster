//
//  MenuBarMenu.swift
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/9/21.
//

import Foundation
import AppKit

class MenuBarMenuItem: CountDownDelegate, Loggable, DataModelAware, AppControllerAware  {

    private lazy var countDown = CountDownTimer(withDelegate: self)
    
    static let defaultImageSize = CGSize(width: 26, height: 26)
    private var reloader: DataModelReloader? = nil

    private weak var timer: Timer?
    
    let menuItemViewController = MenuBarItemViewController()

    enum AlarmState: Int {
        case none
        case normal
        case warning
        case firing1
        case firing2
    }
    
    var firingTime: Date?
    
    var alarmState: AlarmState = .none {
        didSet {
            self.updateDisplayColors()
        }
    }

    
    init() {
        self.reloader = DataModelReloader(for: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(preferencesDidChange(_:)),
                                               name: PreferencesController.DidChangeEvent, object: nil)

        self.updateDisplayColors()
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
    
    func startFlashingTimer() {
        if self.preferencesController.menuBarPreferences.options.contains(.blink) {
            if self.timer == nil {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                    
                    self.logger.log("flashing timer fired")
                    
                    self.updateAlarmState()
                }
                self.timer = timer
            }
        } else {
            self.stopFlashingTimer()
            self.alarmState = .normal
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
            self.buttonTitle = "00:00:00"
        } else {
            self.buttonTitle = ""
        }
    }
    
    func visibilityDidChange(toVisible visible: Bool) {
        self.alarmStateDidChange()
    }
    
    func dataModelDidReload(_ dataModel: DataModel) {
        self.alarmState = .none
        self.alarmStateDidChange()
    }
    
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
            button.imagePosition = .imageLeading
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
    
    
    var button: NSButton? {
        if let button = self.statusBarItem.button {
            return button
        }
        
        return nil
    }
    
    func colorForState(_ state: AlarmState) -> NSColor {
        switch(state) {
            
        case .none:
            return NSColor.white
            
        case .normal:
            return NSColor.white
            
        case .warning:
            return NSColor.systemYellow
            
        case .firing1:
            return NSColor.systemRed

        case .firing2:
            return NSColor.systemYellow
        }
    }
    
    var currentColor: NSColor {
        return colorForState(self.alarmState)
    }
    
    func updateCountDownTitle() {
        if let button = self.button {
            let text = button.attributedTitle
            button.attributedTitle = NSAttributedString(string: text.string, attributes: self.currentTitleAttributes);
        }
    }
    
    lazy var titleBarFont = NSFont(name: "monaco", size: 11)!

    var currentTitleAttributes: [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: self.titleBarFont,
            NSAttributedString.Key.foregroundColor: self.currentColor
        ]
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
                button.attributedTitle = NSAttributedString(string: title, attributes: self.currentTitleAttributes)
            }
        }
    }
    
    private lazy var redRoosterImage : NSImage? = {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            return image.tint(color: NSColor.systemRed)
        }
        
        return nil
    }()
    
    private lazy var whiteRoosterImage: NSImage? = {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            image.isTemplate = true
            return image.tint(color: NSColor.white)
        }
            
        return nil
    }()

    private lazy var yellowRoosterImage : NSImage? = {
        if let image = Bundle(for: type(of: self)).image(forResource: NSImage.Name("RedRoosterIcon")) {
            image.size = CGSize(width: 26, height: 26)
            image.isTemplate = true
            return image.tint(color: NSColor.systemYellow)
        }
        
        return nil
    }()

    func updateAlarmState() {
        let alarmState = self.alarmState
        var newState = alarmState
        
        if self.isAlarmFiring {
            
            if let firingTime = self.firingTime {
                if firingTime.isEqualToOrBeforeDate(Date()) || true {
                    if newState == .firing1 {
                        newState = .firing2
                    } else {
                        newState = .firing1
                    }
                }
            } else {
                newState = .firing1
            }
            
            self.firingTime = Date().addingTimeInterval(1)
            
        } else if let nextDate = self.dataModelController.dataModel.nextAlarmDate,
                  nextDate.isEqualToOrBeforeDate(Date().addingTimeInterval(60 * 2)) {
            newState = .warning
        } else {
            newState = .normal
        }
        
        if newState != alarmState {
            self.logger.log("updating to \(newState.rawValue)")
            self.alarmState = newState
            
            if newState == .normal || newState == .warning {
                self.stopFlashingTimer()
                self.startCountdown()
                self.firingTime = nil
            } else {
                
                
                self.startFlashingTimer()
                self.stopCountdown()
                self.showFinishedMessage()
            }
        }
    }
    
    func updateDisplayColors() {
        switch self.alarmState {
            
        case .none:
            self.buttonImage = self.whiteRoosterImage
            
        case .normal:
            self.buttonImage = self.whiteRoosterImage
            
        case .warning:
            self.buttonImage = self.yellowRoosterImage
            
        case .firing1:
            self.buttonImage = self.redRoosterImage

        case .firing2:
            self.buttonImage = self.yellowRoosterImage
        }
        self.updateCountDownTitle()
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
    
    func countdown(_ countDown: CountDownTimer, didUpdate displayString: String) {
        self.updateAlarmState()
        self.buttonTitle = displayString
    }
    
    func countdownFireDate(_ countDown: CountDownTimer) -> Date? {
        return self.dataModelController.dataModel.nextAlarmDate
    }

    func countdownDisplayFormatter(_ countDown: CountDownTimer) -> TimeDisplayFormatter {
        return self.prefs.options.contains(.shortCountdownFormat) ?
            DigitalClockTimeDisplayFormatter(showSecondsWithMinutes: 2.0):
            VerboseTimeDisplayFormatter(showSecondsWithMinutes: 2.0)
    }
    
    func countdown(_ countDown: CountDownTimer, didFinish displayString: String) {
        self.buttonTitle = displayString
    }
   
    func countdown(_ countDown: CountDownTimer, willStart: Bool) {
        self.buttonTitle = ""
    }
    
    var isAlarmFiring: Bool {
        return self.alarmNotificationController.alarmsAreFiring
    }
    
    func alarmStateDidChange() {
        if self.prefs.options.contains(.showIcon) {
            self.updateAlarmState()
        } else {
            self.stopCountdown()
            self.stopFlashingTimer()
        }
    }
    

    
}

