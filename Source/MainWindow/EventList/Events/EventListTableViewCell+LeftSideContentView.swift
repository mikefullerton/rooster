//
//  EventListTableViewCell+LeftSideContentView.swift
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 12/4/20.
//

import Foundation
import UIKit

extension EventListTableViewCell {
    
    class LeftSideContentView : AbstractLeftSideContentView {

        func setEvent(_ event: EventKitEvent) {
            let startTime = self.shortDateString(event.startDate)
            let endTime = self.shortDateString(event.endDate)
            
            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.eventTitleLabel.text = event.title
            
            let calendar = event.calendar
            self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        }
        
    }
}
