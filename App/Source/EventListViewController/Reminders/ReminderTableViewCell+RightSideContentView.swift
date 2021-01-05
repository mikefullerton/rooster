//
//  EventListTableViewCell+RightSideContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

extension ReminderTableViewCell {
    
    class RightSideContentView : AbstractRightSideContentView {
        
        private var reminder: EventKitReminder?

        func setReminder(_ reminder: EventKitReminder) {
            self.reminder = reminder
            
            self.setLocationURL(reminder.bestLocationURL)

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
        
        override var muteButtonTitle : String {
            return "Snooze"
        }

        
    }
    
}


