//
//  EventListTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/22/20.
//

import Foundation
import UIKit

class EventListTableViewCell : CalendarItemTableViewCell, TableViewRowCell {
    typealias ContentType = RCEvent
    
    private var event: RCEvent?
 
    static var viewHeight: CGFloat {
        return (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }
    
    func viewWillAppear(withData event: RCEvent, indexPath: IndexPath) {
        self.setEvent(event)
        self.updateCalendarBar(withCalendar: event.calendar)
        self.setNeedsLayout()
    }
    
    func setEvent(_ event: RCEvent) {
        self.event = event
        
        self.setLocationURL(event.knownLocationURL)

        if event.alarm.isHappeningNow {
            self.countDownLabel.stopTimer()
            self.alarmIcon.tintColor = event.calendar.color!
            self.stopButton.isEnabled = event.alarm.isFiring
            
            self.alarmIcon.isHidden = false
            self.stopButton.isHidden = false
            self.countDownLabel.isHidden = true
        } else {
            self.countDownLabel.startTimer(fireDate: event.startDate)

            self.alarmIcon.isHidden = true
            self.stopButton.isHidden = true
            self.countDownLabel.isHidden = false
        }
        
        let startTime = event.startDate.shortTimeString
        let endTime = event.endDate.shortTimeString
        
        self.timeLabel.text = "\(startTime) - \(endTime)"
        self.eventTitleLabel.text = event.title
        
        let calendar = event.calendar
        self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.event = nil
    }
    
    @objc override func handleLocationButtonClick(_ sender: UIButton) {
        if let event = self.event {
            event.logger.log("open location button clicked")
            event.openLocationURL()
        } else {
            print("RCEvent is nil when location button clicked")
        }
    }
    
    @objc override func handleMuteButtonClick(_ sender: UIButton) {
        self.event?.stopAlarm()
    }
    
    override var muteButtonTitle : String {
        return "MUTE".localized
    }
}
