//
//  DemoAlarmNotification.swift
//  Rooster
//
//  Created by Mike Fullerton on 12/26/20.
//

import Foundation

#if os(macOS)
import Cocoa
#endif

public class DemoAlarmNotification : AlarmNotification {
    
    let itemIdentifier = UUID().uuidString
    
    public init() {
        super.init(withItemIdentifier: self.itemIdentifier)
    }

    override func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        return false
    }

    public override var item: RCCalendarItem? {
        return self.demoEvent
    }
        
    public lazy var demoEvent: RCEvent = {
        
        let startDate = Date().addingTimeInterval(-60)
        let endDate = startDate.addingTimeInterval(60 * 60)
        
        let alarm = RCAlarm(startDate: startDate,
                          endDate: endDate,
                          isEnabled: true,
                          mutedDate: nil,
                          snoozeInterval: 0)
        
        return RCEvent(withIdentifier: self.itemIdentifier,
                     ekEventID: "",
                     externalIdentifier: "",
                     calendar: self.demoCalendar,
                     subscribed: true,
                     alarm: alarm,
                     startDate: startDate,
                     endDate: endDate,
                     title: "Demo RCEvent",
                     location: "http://apple.com",
                     url: nil,
                     notes: nil,
                     organizer: nil)
    }()
    
    #if os(macOS)
    public lazy var demoCalendar = RCCalendar(withIdentifier: "DEMO_CALENDAR",
                                             ekCalendarID: "",
                                             title: "Demo Calendar",
                                             sourceTitle: "Demo Source",
                                             sourceIdentifier: "Demo",
                                             isSubscribed: true,
                                             color: SDKColor.systemOrange.cgColor)

    #else
    public lazy var demoCalendar = Calendar(withIdentifier: "DEMO_CALENDAR",
                                             ekCalendarID: "",
                                             title: "Demo Calendar",
                                             sourceTitle: "Demo Source",
                                             sourceIdentifier: "Demo",
                                             isSubscribed: true,
                                             color: UIColor.systemOrange.cgColor)
    #endif
    
    
}

