//
//  CalendarItemIconBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarItemIconBar : SimpleStackView {
    
    let insets = SDKEdgeInsets.ten
    let spacing = SDKOffset(horizontal: 10, vertical: 0)
    
    private var calendarItem: RCCalendarItem? = nil
    private lazy var alarmAnimation = SwayAnimation(withView: self.alarmIcon)
    
    init() {
        super.init(direction: .horizontal,
                   insets: self.insets,
                   spacing: self.spacing)
        
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleLocationButtonClick(_ sender: Any?) {
        if let event = self.calendarItem {
            event.logger.log("open location button clicked")
            event.openLocationURL()
        } else {
            print("RCEvent is nil when location button clicked")
        }
    }

    lazy var locationButton: SDKCustomButton = {
        let view = SDKCustomButton(systemImageName: "mappin.and.ellipse",
                                  target: self,
                                  action: #selector(handleLocationButtonClick(_:)),
                                  toolTip: "")
        
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()

    @objc func handleMuteButtonClick(_ sender: Any?) {
        self.calendarItem?.stopAlarmButtonClicked()
    }
    
//    lazy var stopButton: SDKCustomButton = {
//        let view = SDKCustomButton(systemImageName: "speaker.wave.3",
//                                  target: self,
//                                  action: #selector(handleMuteButtonClick(_:)),
//                                  toolTip: "Silence RCAlarm")
//        return view
//    }()

    @objc func handleAlarmButtonClicked(_ sender: Any?) {
        self.calendarItem?.stopAlarmButtonClicked()
    }
    
    lazy var symbolConfig = NSImage.SymbolConfiguration(scale: .large)
    
    lazy var enabledAlarmImage: SDKImage = {
        let image = SDKImage(systemSymbolName: "bell", accessibilityDescription: "mute alarm")?.withSymbolConfiguration(self.symbolConfig)
        return image!
    }()

    lazy var disabledAlarmImage: SDKImage = {
        let image = SDKImage(systemSymbolName: "bell.slash", accessibilityDescription: "mute alarm")?.withSymbolConfiguration(self.symbolConfig)
        return image!
    }()

    lazy var alarmIcon: ImageButton = {
        
        let view = ImageButton()
        
        view.setTarget(self, action: #selector(handleAlarmButtonClicked(_:)))
        view.toolTip = "RCAlarm Enabled"
                       
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        return view
    }()
    
    lazy var swayAnimation: SwayAnimation = {
        return SwayAnimation(withView:self.alarmIcon)
    }()

// TODO: need to create an iCal file to send to Calendar.app
    
//    @objc func handleCalendarButtonClicked(_ sender: SDKImageButton) {
//
//        let config = NSWorkspace.OpenConfiguration()
//        config.promptsUserIfNeeded = false
//
//
//        if  let calendarItem = self.calendarItem,
//            let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal"),
//            let url = URL(string: "iCal:x?eventid=\(calendarItem.externalIdentifier)") {
//
//
//
//            NSWorkspace.shared.open([url],
//                                   withApplicationAt: calURL,
//                                    configuration: config) { [weak self] (runningApplication, error) in
//
//                print("\(String(describing: runningApplication)): \(String(describing: error))")
//            }
//        }
//    }

//    lazy var calendarIcon: SDKImageButton = {
//        let view = SDKImageButton(systemImageName: "calendar",
//                                  target: self,
//                                  action: #selector(handleCalendarButtonClicked(_:)),
//                                  toolTip: "Open in Calendar.app")
//
//        return view
//
//    }()
    
    func update(withCalendarItem calendarItem: RCCalendarItem) {
        
        self.calendarItem = calendarItem
        self.alarmIcon.isEnabled = true
        
        let alarm = calendarItem.alarm
        
        self.alarmIcon.image = alarm.isFinished ? self.disabledAlarmImage : self.enabledAlarmImage
        if calendarItem.alarm.isFiring {
            DispatchQueue.main.async {
                self.alarmAnimation.startAnimating()
            }
        } else {
            self.alarmAnimation.stopAnimating()
        }

        var views:[SDKView] = []

        if let locationURL = calendarItem.knownLocationURL {
            self.locationButton.toolTip = "Meeting URL: \(locationURL.absoluteString)"
            views.append(self.locationButton)
        }
        
        views.append(self.alarmIcon)
        
        self.setContainedViews(views)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.calendarItem = nil
        self.locationButton.toolTip = ""
    }
}

