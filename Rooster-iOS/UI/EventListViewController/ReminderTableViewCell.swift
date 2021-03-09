//
//  ReminderTableViewCell.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/5/20.
//

import Foundation
import UIKit

class ReminderTableViewCell: CalendarItemTableViewCell, TableViewRowCell {
    typealias ContentType = EventKitReminder

    private var reminder: EventKitReminder?

    static var viewHeight: CGFloat {
        (EventListTableViewCell.labelHeight + EventListTableViewCell.verticalPadding) * 3 + 20
    }

    func viewWillAppear(withData reminder: EventKitReminder, indexPath: IndexPath) {
        self.setReminder(reminder)
        self.updateCalendarBar(withCalendar: reminder.calendar)
        self.setNeedsLayout()
    }
    func setReminder(_ reminder: EventKitReminder) {
        self.reminder = reminder

        self.setLocationURL(reminder.knownLocationURL)

        if reminder.alarm.isHappeningNow {
            self.countDownLabel.stopTimer()
            self.alarmIcon.tintColor = reminder.calendar.color!
            self.stopButton.isEnabled = reminder.alarm.isFiring

            self.alarmIcon.isHidden = false
            self.stopButton.isHidden = false
            self.countDownLabel.isHidden = true
        } else {
            self.countDownLabel.startTimer(fireDate: reminder.dueDate)

            self.alarmIcon.isHidden = true
            self.stopButton.isHidden = true
            self.countDownLabel.isHidden = false
        }

        self.timeLabel.text = "EventKitReminder Due at: \(reminder.alarm.startDate))"
        self.eventTitleLabel.text = reminder.title

        let calendar = reminder.calendar
        self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.reminder = nil
    }

    @objc override func handleLocationButtonClick(_ sender: UIButton) {
        if let reminder = self.reminder {
            reminder.openLocationURL()
        }
    }

    @objc override func handleMuteButtonClick(_ sender: UIButton) {
        self.reminder?.snoozeAlarm()
    }

    override var muteButtonTitle: String {
        "SNOOZE".localized
    }
}
