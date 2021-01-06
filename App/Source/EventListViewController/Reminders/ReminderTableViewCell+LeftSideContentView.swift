//
//  EventListTableViewCell+LeftSideContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

extension ReminderTableViewCell {
    
    class LeftSideContentView : AbstractLeftSideContentView {

        func setReminder(_ reminder: Reminder) {
            self.timeLabel.text = "Reminder Due at: \(reminder.alarm.startDate))"
            self.eventTitleLabel.text = reminder.title

            let calendar = reminder.calendar
            self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        }
        
    }
}
