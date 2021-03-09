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

open class CalendarItemListViewCell: ListViewRowController, CountDownTextFieldDelegate {
    public let contentInsets = SDKEdgeInsets(top: 14, left: 14, bottom: 14, right: 10)

    public var scheduleItem: ScheduleItem?

//    var eventKitCalendar: EventKitCalendarItem? {
//        return self.scheduleItem?.calendar.eventKitCalendar
//    }

    public let contentViews = ContentViews()

    override public func viewDidLoad() {
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

    override public func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
        self.scheduleItem = nil
        self.contentViews.timePassingView.stopTimer()
        self.contentViews.locationButton.toolTip = ""
    }

    override open class func preferredSize(forContent content: Any?) -> CGSize {
        var height = 70.0

        if let scheduleItem = content as? ScheduleItem,
            scheduleItem.dateRange == nil {
            height = 40
        }

        if AppControllers.shared.preferences.calendar.options.contains(.showCalendarName) {
            height += 10
        }

        return CGSize(width: -1, height: height)
    }

    @objc func handleAlarmButtonClicked(_ sender: Any?) {
        self.scheduleItem?.stopAlarmButtonClicked()
    }

    @objc func handleLocationButtonClick(_ sender: Any?) {
        if let event = self.scheduleItem {
            event.logger.log("open location button clicked")
            _ = event.openLocationURL()
        } else {
            print("EventKitEvent is nil when location button clicked")
        }
    }

    // MARK: - Utils

    public func countDownDidFinish(_ countDownTextField: CountDownTextField) {
        if countDownTextField === self.contentViews.startCountDownLabel {
            countDownTextField.isHidden = true

            if let item = self.scheduleItem,
                let endDate = item.dateRange?.endDate {
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

    // swiftlint:disable todo
    // TODO: need to create an iCal file to send to Calendar.app
    // swiftlint:enable todo
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

    func configureLocationButton(onlyIfURLExists: Bool) -> SDKButton? {
        var showButton = !onlyIfURLExists

        if  let scheduleItem = self.scheduleItem,
            let locationURL = scheduleItem.knownLocationURL {
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

    public func updateActionButtons(_ actionButtons: inout [SDKView]) {
    }

    public func updateLeadingActionButtons(_ actionButtons: inout [SDKView]) {
    }

    private func createDefaultActionButtons() -> [SDKView] {
        var views: [SDKView] = []

        if let scheduleItem = self.scheduleItem {
            if let alarm = scheduleItem.alarm {
                if let locationButton = self.configureLocationButton(onlyIfURLExists: false) {
                    views.append(locationButton)
                }

                self.contentViews.alarmIcon.image = alarm.isFinished ?
                    self.contentViews.disabledAlarmImage :
                    self.contentViews.enabledAlarmImage

                self.contentViews.alarmIcon.isEnabled = !alarm.dateRange.isInThePast

                views.append(self.contentViews.alarmIcon)
            } else {
                if let locationButton = self.configureLocationButton(onlyIfURLExists: true) {
                    views.append(locationButton)
                }
            }
        }

        return views
    }

    var itemTypeString: String {
        ""
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

    func updateCommonUI() {
        if let scheduleItem = self.scheduleItem {
            self.contentViews.eventTitleLabel.stringValue = scheduleItem.title

            if let dateRange = scheduleItem.dateRange {
                self.contentViews.startTimeLabel.isHidden = false
                self.contentViews.startTimeLabel.stringValue = dateRange.startDate.shortTimeString

                self.contentViews.endTimeLabel.isHidden = false
                self.contentViews.endTimeLabel.stringValue = dateRange.endDate.shortTimeString
            } else {
                self.contentViews.startTimeLabel.isHidden = true
                self.contentViews.startTimeLabel.stringValue = ""

                self.contentViews.endTimeLabel.isHidden = true
                self.contentViews.endTimeLabel.stringValue = ""
            }

            var views: [SDKView] = []

            if scheduleItem.isRecurring {
                views.append(self.contentViews.recurringIcon)
            }

            self.contentViews.infoBar.setContainedViews(views)
        }
    }

    func updateCalendarUI() {
        if let calendar = self.scheduleItem?.calendar {
            self.contentViews.calendarColorBar.toolTip = "Calendar: \(calendar.title) (\(calendar.source.title))"
            self.contentViews.eventTitleLabel.toolTip = "Calendar: \(calendar.title) (\(calendar.source.title))"

            let calendarPrefs = AppControllers.shared.preferences.calendar
            self.contentViews.itemTypeLabel.isHidden = calendarPrefs.options.contains(.showCalendarName) == false
            self.contentViews.itemTypeLabel.stringValue = "\(calendar.title) (\(calendar.source.title))"

            if let calendarColor = calendar.color {
                self.contentViews.calendarColorBar.color = calendarColor
    //            self.itemTypeLabel.textColor = calendarColor
            } else {
                self.contentViews.calendarColorBar.color = SDKColor.systemGray
            }
        }
    }

    func startAlarmAnimationIfNeeded() {
        if let alarm = self.scheduleItem?.alarm,
            alarm.isFiring {
            DispatchQueue.main.async {
                self.contentViews.alarmAnimation.startAnimating()
            }
        }
    }

    func updateForCurrentEvent() {
        if  let scheduleItem = self.scheduleItem,
            let dateRange = scheduleItem.dateRange {
            self.startAlarmAnimationIfNeeded()

            self.contentViews.timePassingView.dateRange = dateRange
            self.contentViews.timePassingView.isHidden = false
            self.contentViews.endCountDownLabel.isHidden = false
            self.contentViews.endCountDownLabel.startCountDown(withFireDate: dateRange.endDate)
        }
    }

    func updateForPastEvent() {
    }

    func updateForFutureEvent() {
        if let scheduleItem = self.scheduleItem, let dateRange = scheduleItem.dateRange {
            self.contentViews.startCountDownLabel.isHidden = false
            self.contentViews.startCountDownLabel.startCountDown(withFireDate: dateRange.startDate)
        }
    }

    func updateForTimelessEvent() {
    }

    func updateTrailingActionButtons() {
        var views = self.createDefaultActionButtons()
        self.updateActionButtons(&views)
        self.contentViews.actionButtons.setContainedViews(views)
    }

    func updateLeadingActionButton() {
        var views: [SDKView] = []
        self.updateLeadingActionButtons(&views)
        self.contentViews.leadingActionButtons.setContainedViews(views)
    }

    override open func willDisplay(withContent content: Any?) {
        guard let scheduleItem = content as? ScheduleItem else {
            return
        }

        self.preferredContentSize = Self.preferredSize(forContent: content)

        self.scheduleItem = scheduleItem

        self.resetUI()

        self.updateCalendarUI()
        self.updateCommonUI()

//        self.alarmIcon.isEnabled = true
        self.updateLeadingActionButton()
        self.updateTrailingActionButtons()

        if let dateRange = scheduleItem.dateRange {
            if dateRange.isHappeningNow {
                self.updateForCurrentEvent()
            } else if dateRange.isInThePast {
                self.updateForPastEvent()
            } else if dateRange.isInTheFuture {
                self.updateForFutureEvent()
            }
        } else {
            self.updateForTimelessEvent()
        }

        self.view.needsLayout = true
        self.view.needsDisplay = true
    }
}
