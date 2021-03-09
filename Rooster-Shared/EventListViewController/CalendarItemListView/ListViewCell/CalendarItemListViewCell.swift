//
//  CalendarItemListViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import RoosterCore
#if os(macOS)
import Cocoa
#else
import UIKit
#endif


class CalendarItemListViewCell : ListViewRowController<EventListRowItem>, CountDownTextFieldDelegate {
    
    let contentInsets = SDKEdgeInsets(top: 14, left: 14, bottom: 14, right: 10)

    private(set) var rowItem: EventListRowItem?

    public let contentViews = ContentViews()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.contentViews.owner = self
        
        self.view.sdkLayer.cornerRadius = 0.0
        self.view.sdkLayer.backgroundColor = NSColor.clear.cgColor

//        self.view.sdkLayer.cornerRadius = 6.0
        self.view.sdkLayer.borderWidth = 0.5
        self.view.sdkLayer.borderColor = SDKColor.separatorColor.cgColor
        self.view.sdkLayer.masksToBounds = true
        
        self.contentViews.addViews()
        self.addHighlightBackgroundView()
    }
    
    override func prepareForReuse() {
        self.resetUI()
        self.rowItem = nil
        self.contentViews.timePassingView.stopTimer()
        self.contentViews.locationButton.toolTip = ""
    }
    
    open class override func preferredSize(forContent content: Any?) -> CGSize {
        
        var height = 70.0
        
        if let rowItem = content as? EventListRowItem,
            (!rowItem.calendarItem.hasDates || rowItem.calendarItem.isAllDay) {
            height = 40
        }
        
        if Controllers.preferences.calendar.options.contains(.showCalendarName) {
            height += 10
        }
        
        return CGSize(width: -1, height: height)
    }

    @objc func handleAlarmButtonClicked(_ sender: Any?) {
        self.rowItem?.calendarItem.stopAlarmButtonClicked()
    }
    
    @objc func handleLocationButtonClick(_ sender: Any?) {
        if let event = self.rowItem?.calendarItem {
            event.logger.log("open location button clicked")
            _ = event.openLocationURL()
        } else {
            print("RCEvent is nil when location button clicked")
        }
    }
    
    // MARK: - Utils
    
    func countDownDidFinish(_ countDownTextField: CountDownTextField) {
        if countDownTextField === self.contentViews.startCountDownLabel {
            countDownTextField.isHidden = true
            
            if let item = self.rowItem?.calendarItem,
                let endDate = item.alarm.endDate,
                !item.isAllDay {
                    self.contentViews.endCountDownLabel.isHidden = false
                    self.contentViews.endCountDownLabel.startCountDown(withFireDate: endDate)
            } else {
                self.contentViews.endCountDownLabel.isHidden = true
            }
            
        } else if countDownTextField === self.contentViews.endCountDownLabel {
            countDownTextField.isHidden = true
        }
    }
    
    // MARK: - Action buttons
        
    // TODO: need to create an iCal file to send to Calendar.app
//    @objc func handleCalendarButtonClicked(_ sender: SDKImageButton) {
//            let config = NSWorkspace.OpenConfiguration()
//            config.promptsUserIfNeeded = false
//
//
//            if  let calendarItem = self.calendarItem,
//                let calURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.iCal"),
//                let url = URL(string: "iCal:x?eventid=\(calendarItem.externalIdentifier)") {
//
//
//
//                NSWorkspace.shared.open([url],
//                                       withApplicationAt: calURL,
//                                        configuration: config) { [weak self] (runningApplication, error) in
//
//                    print("\(String(describing: runningApplication)): \(String(describing: error))")
//                }
//            }
//    }
    
    func configureLocationButton(onlyIfURLExists: Bool,
                                 forRowItem rowItem: EventListRowItem) -> SDKButton? {

        var showButton = !onlyIfURLExists

        if let locationURL = rowItem.calendarItem.knownLocationURL {

            if onlyIfURLExists {
                showButton = true
            }

            self.contentViews.locationButton.toolTip = "Meeting URL: \(locationURL.absoluteString)"
            self.contentViews.locationButton.isEnabled = true
        } else {
            self.contentViews.locationButton.isEnabled = false
            self.contentViews.locationButton.toolTip = "No location found"
        }

        return showButton ? self.contentViews.locationButton : nil
    }

    public func updateActionButtons(_ actionButtons: inout [SDKView],
                                    forRowItem rowItem: EventListRowItem) {
    }

    private func createDefaultActionButtons(forRowItem rowItem: EventListRowItem) -> [SDKView] {
        var views:[SDKView] = []

        if rowItem.calendarItem.isAllDay {
            if let locationButton = self.configureLocationButton(onlyIfURLExists: true,
                                                                 forRowItem: rowItem) {
                views.append(locationButton)
            }

        } else {
            if rowItem.calendarItem.hasDates {
                if let locationButton = self.configureLocationButton(onlyIfURLExists: false,
                                                                     forRowItem: rowItem) {
                    views.append(locationButton)
                }

                self.contentViews.alarmIcon.image = rowItem.calendarItem.alarm.isFinished ?
                                                    self.contentViews.disabledAlarmImage :
                                                    self.contentViews.enabledAlarmImage

                self.contentViews.alarmIcon.isEnabled = !rowItem.calendarItem.alarm.isInThePast
                views.append(self.contentViews.alarmIcon)
            }
        }

       return views
    }

    var itemTypeString: String {
        return ""
    }

    func resetUI() {
        self.contentViews.eventTitleLabel.stringValue = ""
        self.contentViews.startCountDownLabel.stringValue = ""
        self.contentViews.startCountDownLabel.stopCountDown()
        self.contentViews.endCountDownLabel.stopCountDown()
        self.contentViews.endCountDownLabel.stringValue = ""
        self.contentViews.startCountDownLabel.isHidden = true
        self.contentViews.endCountDownLabel.isHidden = true
        self.contentViews.notAcceptedOverlay.isHidden = true
        self.contentViews.pastDueOverlay.isHidden = true
        self.contentViews.timePassingView.isHidden = true
        self.contentViews.actionButtons.isHidden = false

        self.contentViews.alarmAnimation.stopAnimating()
    }

    func eventTitle(forRowItem rowItem: EventListRowItem) -> String {
        return rowItem.calendarItem.title
    }

    func updateCommonUI(forRowItem rowItem: EventListRowItem) {

        self.contentViews.eventTitleLabel.stringValue = self.eventTitle(forRowItem: rowItem)
        if !rowItem.calendarItem.isAllDay,
            rowItem.calendarItem.hasDates {
            self.contentViews.startTimeLabel.isHidden = false
            self.contentViews.startTimeLabel.stringValue = rowItem.calendarItem.alarm.startDate?.shortTimeString ?? ""

            self.contentViews.endTimeLabel.isHidden = false
            self.contentViews.endTimeLabel.stringValue = rowItem.calendarItem.alarm.endDate?.shortTimeString ?? ""
        } else {
            self.contentViews.startTimeLabel.isHidden = true
            self.contentViews.startTimeLabel.stringValue = ""

            self.contentViews.endTimeLabel.isHidden = true
            self.contentViews.endTimeLabel.stringValue = ""

        }

        var views:[SDKView] = []
        
        if rowItem.calendarItem.isRecurring {
            views.append(self.contentViews.recurringIcon)
        }
        
        self.contentViews.infoBar.setContainedViews(views)
    }

    func updateCalendarUI(forRowItem rowItem: EventListRowItem) {
        let calendar = rowItem.calendarItem.calendar

        self.contentViews.calendarColorBar.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        self.contentViews.eventTitleLabel.toolTip = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"

        self.contentViews.itemTypeLabel.isHidden = Controllers.preferences.calendar.options.contains(.showCalendarName) == false
        self.contentViews.itemTypeLabel.stringValue = "\(calendar.title) (\(calendar.sourceTitle))"

        if let calendarColor = calendar.color {
            self.contentViews.calendarColorBar.color = calendarColor
//            self.itemTypeLabel.textColor = calendarColor
        } else {
            self.contentViews.calendarColorBar.color = SDKColor.systemGray
        }
    }
    
    func updateForCurrentEvent(forRowItem rowItem: EventListRowItem) {

        if  !rowItem.calendarItem.isAllDay,
            let startDate = rowItem.calendarItem.alarm.startDate,
            let endDate = rowItem.calendarItem.alarm.endDate {

            if rowItem.calendarItem.alarm.isFiring {
                DispatchQueue.main.async {
                    self.contentViews.alarmAnimation.startAnimating()
                }
            }

            self.contentViews.timePassingView.set(startDate: startDate,
                                 endDate: endDate)

            self.contentViews.endCountDownLabel.isHidden = false
            self.contentViews.endCountDownLabel.startCountDown(withFireDate: endDate)
        }
    }

    func updateForPastEvent(forRowItem rowItem: EventListRowItem) {
        if !rowItem.calendarItem.isAllDay {
            self.contentViews.pastDueOverlay.isHidden = false
        }
    }

    func updateForFutureEvent(forRowItem rowItem: EventListRowItem) {
        if  !rowItem.calendarItem.isAllDay,
            let startDate = rowItem.calendarItem.alarm.startDate {
            self.contentViews.startCountDownLabel.isHidden = false
            self.contentViews.startCountDownLabel.startCountDown(withFireDate: startDate)
        }
    }

    func updateForTimelessEvent(forRowItem rowItem: EventListRowItem) {
    }

    override func viewWillAppear(withContent rowItem: EventListRowItem) {

        self.rowItem = rowItem

        self.resetUI()

        self.updateCalendarUI(forRowItem: rowItem)
        self.updateCommonUI(forRowItem: rowItem)

//        self.alarmIcon.isEnabled = true

        var views = self.createDefaultActionButtons(forRowItem: rowItem)

        self.updateActionButtons(&views, forRowItem: rowItem)

        self.contentViews.actionButtons.setContainedViews(views)

        if rowItem.calendarItem.alarm.isHappeningNow {
            self.updateForCurrentEvent(forRowItem: rowItem)

        } else if rowItem.calendarItem.alarm.isInThePast {
            self.updateForPastEvent(forRowItem: rowItem)

        } else if rowItem.calendarItem.alarm.isInTheFuture {
            self.updateForFutureEvent(forRowItem: rowItem)
        } else {
            self.updateForTimelessEvent(forRowItem: rowItem)
        }

        self.view.needsLayout = true
        self.view.needsDisplay = true
    }

    
}
