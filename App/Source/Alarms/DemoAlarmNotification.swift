//
//  DemoAlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation
import UIKit

class DemoAlarmNotification : AlarmNotification {
    
    let itemIdentifier = UUID().uuidString
    
    init() {
        super.init(withItemIdentifier: self.itemIdentifier)
    }

    override func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        return false
    }

    override var item: Alarmable? {
        return self.demoEvent
    }
        
    lazy var demoEvent: EventKitEvent = {
        
        let startDate = Date().addingTimeInterval(-60)
        let endDate = startDate.addingTimeInterval(60 * 60)
        
        let alarm = EventKitAlarm(withState: .firing,
                                  startDate: startDate,
                                  endDate: endDate,
                                  isEnabled: true,
                                  snoozeInterval: 0)
        
        return EventKitEvent(withIdentifier: self.itemIdentifier,
                             ekEventID: "",
                             calendar: self.demoCalendar,
                             subscribed: true,
                             alarm: alarm,
                             startDate: startDate,
                             endDate: endDate,
                             title: "Demo Event",
                             location: "http://apple.com",
                             url: nil,
                             notes: nil,
                             noteURLS: nil,
                             organizer: nil)
    }()
    
    lazy var demoCalendar = EventKitCalendar(withIdentifier: "DEMO_CALENDAR",
                                             ekCalendarID: "",
                                             title: "Demo Calendar",
                                             sourceTitle: "Demo Source",
                                             sourceIdentifier: "Demo",
                                             isSubscribed: true,
                                             color: UIColor.systemOrange.cgColor)
    
}

