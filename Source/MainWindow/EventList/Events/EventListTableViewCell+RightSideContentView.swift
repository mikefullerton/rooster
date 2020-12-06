//
//  EventListTableViewCell+RightSideContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

extension EventListTableViewCell {
    
    class RightSideContentView : AbstractRightSideContentView {
        
        private var event: EventKitEvent?

        func setEvent(_ event: EventKitEvent) {
            self.event = event
            
            self.setLocationURL(event.bestLocationURL)

            if event.isHappeningNow {
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
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            self.event = nil
        }
        
        @objc override func handleLocationButtonClick(_ sender: UIButton) {
            if let event = self.event {
                AlarmController.instance.openEventLocationURL(forItem: event)
            }
        }
        
        @objc override func handleMuteButtonClick(_ sender: UIButton) {
            self.event?.stopAlarm()
        }
        
        override var muteButtonTitle : String {
            return "Mute"
        }

    }
    
}
