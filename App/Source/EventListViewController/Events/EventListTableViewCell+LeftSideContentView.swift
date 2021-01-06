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

        func setEvent(_ event: Event) {
            let startTime = event.startDate.shortDateString
            let endTime = event.endDate.shortDateString
            
            self.timeLabel.text = "\(startTime) - \(endTime)"
            self.eventTitleLabel.text = event.title
            
            let calendar = event.calendar
            self.calendarTitleLabel.text = "Calendar: \(calendar.title) (\(calendar.sourceTitle))"
        }
        
    }
}
