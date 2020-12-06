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

        func setReminder(_ reminder: EventKitReminder) {
            self.timeLabel.text = "Reminder Due at: \(self.shortDateString(reminder.dueDate))"
            self.eventTitleLabel.text = reminder.title

            let calendar = reminder.calendar
            self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        }
        
    }
}
