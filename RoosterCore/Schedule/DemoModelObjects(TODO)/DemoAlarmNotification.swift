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

public class DemoAlarmNotification: AlarmNotification {
    let itemIdentifier = UUID().uuidString

    public init() {
        super.init(withItemIdentifier: self.itemIdentifier)
    }

    override func shouldStop(ifNotContainedIn dataModelIdentifiers: Set<String>) -> Bool {
        false
    }

    override public var item: EventKitCalendarItem? {
        self.demoEvent
    }

    public lazy var demoEvent: RCDemoEvent = {
        let startDate = Date().addingTimeInterval(-60)
        let endDate = startDate.addingTimeInterval(60 * 60)

        let alarm = ScheduleItemAlarm(startDate: startDate,
                                      endDate: endDate,
                                      isEnabled: true,
                                      finishedDate: nil,
                                      snoozeInterval: 0,
                                      canExpire: true)

        return RCDemoEvent(withID: self.itemIdentifier,
                           alarm: alarm,
                           title: "Demo Event",
                           calendar: self.demoCalendar,
                           startDate: startDate,
                           endDate: endDate,
                           location: "http://apple.com")
    }()

    public lazy var demoCalendar = RCDemoCalendar(withIdentifier: "DEMO_CALENDAR",
                                                  ekCalendarID: "",
                                                  title: "Demo Calendar",
                                                  sourceTitle: "Demo Source",
                                                  sourceIdentifier: "Demo",
                                                  isSubscribed: true,
                                                  color: SDKColor.systemOrange.cgColor)
}
