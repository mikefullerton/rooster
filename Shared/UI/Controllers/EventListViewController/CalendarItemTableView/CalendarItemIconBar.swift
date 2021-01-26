//
//  CalendarItemIconBar.swift
//  Rooster
//
//  Created by Mike Fullerton on 1/24/21.
//

import Foundation
#if os(macOS)
import Cocoa
#else
import UIKit
#endif

class CalendarItemIconBar : SimpleStackView {
    
    let insets = SDKEdgeInsets.ten
    let spacing = SDKOffset(horizontal: 10, vertical: 0)
    
    private var calendarItem: CalendarItem?
    
    init() {
        super.init(frame: CGRect.zero,
                   direction: .horizontal,
                   insets: self.insets,
                   spacing: self.spacing)
        
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handleLocationButtonClick(_ sender: SDKButton) {
        if let event = self.calendarItem {
            event.logger.log("open location button clicked")
            event.openLocationURL()
        } else {
            print("Event is nil when location button clicked")
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

    @objc func handleMuteButtonClick(_ sender: SDKButton) {
        self.calendarItem?.stopAlarmButtonClicked()
    }
    
    lazy var stopButton: SDKCustomButton = {
        let view = SDKCustomButton(systemImageName: "speaker.wave.3",
                                  target: self,
                                  action: #selector(handleMuteButtonClick(_:)),
                                  toolTip: "Silence Alarm")
        return view
    }()

    @objc func handleAlarmButtonClicked(_ sender: SDKCustomButton) {
        self.calendarItem?.stopAlarmButtonClicked()
//        self.calendarItem?.stopAlarmButtonClicked()
    }

    lazy var alarmIcon: SDKCustomButton = {
        
        let view = SDKCustomButton(systemImageName: "bell",
                                  target: self,
                                  action: #selector(handleAlarmButtonClicked(_:)),
                                  toolTip: "Alarm Enabled")
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

//        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
//        pulseAnimation.duration = 0.4
//        pulseAnimation.fromValue = 0.5
//        pulseAnimation.toValue = 1.0
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        pulseAnimation.autoreverses = true
//        pulseAnimation.repeatCount = .greatestFiniteMagnitude
//        view.layer.add(pulseAnimation, forKey: nil)
//
//        let pulse = CASpringAnimation(keyPath: "transform.scale")
//        pulse.duration = 0.4
//        pulse.fromValue = 1.0
//        pulse.toValue = 1.12
//        pulse.autoreverses = true
//        pulse.repeatCount = .infinity
//        pulse.initialVelocity = 0.5
//        pulse.damping = 0.8
//        view.layer.add(pulse, forKey: nil)
        
        return view
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
    
    func update(withCalendarItem calendarItem: CalendarItem) {
        
        self.calendarItem = calendarItem
        
        var views:[SDKView] = []

        if let locationURL = calendarItem.knownLocationURL {
            self.locationButton.toolTip = locationURL.absoluteString
            views.append(self.locationButton)
        }
        
//        views.append(self.stopButton)
        views.append(self.alarmIcon)
        
//        views.append(self.calendarIcon)
        
        self.stopButton.isEnabled = calendarItem.alarm.isFiring
        
        self.setContainedViews(views)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.calendarItem = nil
        self.locationButton.toolTip = ""
    }
    

    
}

